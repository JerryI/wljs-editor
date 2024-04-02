BeginPackage["Notebook`Editor`", {
    "CodeParser`", 
    "JerryI`Notebook`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Transactions`",
    "JerryI`Misc`Events`",
    "JerryI`WLX`",
    "JerryI`WLX`Importer`",
    "JerryI`Misc`WLJS`Transport`",
    "Notebook`Editor`FrontendObject`"
}]

NotebookEditorChannel::usage = "used to transfer extra events"

Begin["`Internal`"]

truncatedTemplate = ImportComponent[ FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory, "templates", "truncated.wlx"}] ];
truncatedTemplate = truncatedTemplate["Data"->"``", "Size"->"``"];

NotebookEditorChannel = CreateUUID[];

rootFolder = $InputFileName // DirectoryName;

evaluator  = StandardEvaluator["Name" -> "Wolfram Evaluator", "InitKernel" -> init, "Priority"->(999)];

    StandardEvaluator`ReadyQ[evaluator, k_] := (
        If[! TrueQ[k["ReadyQ"] ] || ! TrueQ[k["ContainerReadyQ"] ],
            EventFire[t, "Error", "Kernel is not ready"];
            StandardEvaluator`Print[evaluator, "Kernel is not ready"];
            False
        ,


            True
        ]
    );

    StandardEvaluator`Evaluate[evaluator, k_, t_] := Module[{list},
     t["Evaluator"] = Notebook`Editor`WolframEvaluator;

     With[{check = CheckSyntax[t["Data"] ]},
        If[! TrueQ[check],
            EventFire[t, "Error", check];
            Echo["Syntax Error!"];
            Return[$Failed];
        ];

        If[! TrueQ[k["ReadyQ"] ],
            Echo[k["ReadyQ"] ];
            EventFire[t, "Error", "Kernel is not ready"];
            Return[$Failed];
        ];

        list = SplitExpression[t["Data"] ];
        MapIndexed[
            With[{message = StringTrim[#1], index = #2[[1]], transaction = Transaction[]},
                If[StringTake[message, -1] === ";", 
                    transaction["Nohup"] = True;
                    transaction["EvaluationContext"] = t["EvaluationContext"];
                    transaction["Data"] = StringDrop[message, -1];
                ,
                    transaction["EvaluationContext"] = t["EvaluationContext"];
                    transaction["Data"] = message;
                ];
                (*  FIXME TODO Normal OUT Support *)
                (*  FIXME TODO Normal OUT Support *)
                (*  FIXME TODO Normal OUT Support *)
                (*  FIXME TODO Normal OUT Support *)
                
                transaction["Evaluator"] = Notebook`Editor`WolframEvaluator;
                
                (* check if it is the last one *)
                If[index === Length[list],
                    EventHandler[transaction, {
                        (* capture successfull event of the last transaction to end the process *)  
                        "Result" -> Function[data, 
                            EventFire[t, "Result", data];
                            EventFire[t, "Finished", True];
                        ],
                        (* fwd the rest *)
                        name_ :> Function[data, EventFire[t, name, data] ]
                    }];          
                ,
                    EventHandler[transaction, {
                        name_ :> Function[data, EventFire[t, name, data] ]
                    }];                
                ];

                StandardEvaluator`Print[evaluator, "Kernel`Submit!"];
                Kernel`Submit[k, transaction];
            ]&
        ,  list];
    ];      
  ];  

init[k_] := Module[{},
    Print["Kernel init..."];
    With[{channel = NotebookEditorChannel, tt = truncatedTemplate},
        Kernel`Init[k,
            Print["Init internal communication"];
            Internal`Kernel`TruncatedOutputTemplate = tt;
            Internal`Kernel`CommunicationChannel = Internal`Kernel`Stdout[channel];
        ];
    ];
    Kernel`Init[k, 
        Print["Init normal Kernel (Local)"];
        Notebook`Editor`WolframEvaluator = Function[t, 
        With[{hash = CreateUUID[]},
          Block[{
            Global`$EvaluationContext = Join[t["EvaluationContext"], <|"ResultCellHash" -> hash|>]
          },
            With[{result = (ToExpression[ t["Data"], InputForm, Hold] /. Out -> $PreviousOut) // ReleaseHold },
                If[KeyExistsQ[t, "Nohup"],
                    EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Result", <|"Data" -> Null |> ];
                ,   
                    (* check length *)
                    With[{string = ToString[result, StandardForm]},
                        If[StringLength[string] < 10000,
                            EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Result", <|"Data" -> string, "Meta"->Sequence["Hash"->hash] |> ];
                        ,
                            With[{truncated = ToString[result, InputForm]},
                                EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Result", <|"Data" -> StringTemplate[Internal`Kernel`TruncatedOutputTemplate][StringLength[string], StringTake[truncated, Min[StringLength[truncated], 5000] ] ], "Meta"->Sequence["Hash"->hash, "Display"->"html"] |> ];
                            ]
                        ]
                    ]
                    
                ];
                
                (*  FIXME TODO Normal OUT Support *)
                $PreviousOut[] = result;
            ];
          ];
        ] ];
    ];

    (* !!!! Unknown bug with Boxes... have to do it separately *)
    With[{p = Import[FileNameJoin[{rootFolder, "Boxes.wl"}], "String"]},
        Kernel`Init[k,   ToExpression[p, InputForm]; , "Once"->True];
    ];
]

SplitExpression[astr_] := With[{str = StringReplace[astr, {"$Pi$"->"\[Pi]"}]},
  Select[Select[(StringTake[str, Partition[Join[{1}, #, {StringLength[str]}], 2]] &@
   Flatten[{#1 - 1, #2 + 1} & @@@ 
     Sort@
      Cases[
       CodeParser`CodeConcreteParse[str, 
         CodeParser`SourceConvention -> "SourceCharacterIndex"][[2]], 
       LeafNode[Token`Newline, _, a_] :> Lookup[a, Source, Nothing]]]), StringQ], (StringLength[#]>0) &]
];

CheckSyntax[str_String] := 
    Module[{syntaxErrors = Cases[CodeParser`CodeParse[str],(ErrorNode|AbstractSyntaxErrorNode|UnterminatedGroupNode|UnterminatedCallNode)[___],Infinity]},
        If[Length[syntaxErrors]=!=0 ,
            

            Return[StringRiffle[
                TemplateApply["Syntax error `` at line `` column ``",
                    {ToString[#1],Sequence@@#3[CodeParser`Source][[1]]}
                ]&@@@syntaxErrors

            , "\n"], Module];
        ];
        Return[True, Module];
    ];


End[]

EndPackage[]