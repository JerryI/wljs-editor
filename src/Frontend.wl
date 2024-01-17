BeginPackage["Notebook`Editor`", {
    "CodeParser`", 
    "JerryI`Notebook`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Transactions`",
    "JerryI`Misc`Events`"
}]

Begin["`Internal`"]

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
                (*If[StringTake[message, -1] === ";", transaction["Nohup"] = True];*)
                transaction["Data"] = message;
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
                StandardEvaluator`Print[evaluator, transaction["Data"] ];
                Kernel`Submit[k, transaction];
            ]&
        ,  list];
    ];      
  ];  

init[k_] := Module[{},
    Print["Kernel init..."];
    Kernel`Init[k, 
        Print["Init normal Kernel (Local)"];
        Notebook`Editor`WolframEvaluator = Function[t, 
            Print["Got it!"];
            With[{result = ToExpression[ t["Data"], InputForm, Hold] // ReleaseHold },
                EventFire[Internal`Kernel`Stdout[ t["Hash"] ], "Result", <|"Data" -> ToString[result, StandardForm] |> ];
                result
            ]
        ];
    ]
]

SplitExpression[astr_] := With[{str = StringReplace[astr, {"%"->"Global`$out", "$Pi$"->"\[Pi]"}]},
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