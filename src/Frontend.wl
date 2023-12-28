Begin["Notebook`Editor`"]

<<CodeParser`;

evaluator = StaticEvaluator["Q"->(True&), "Priority"->-1]
evaluator /: StandardEvaluator`Evaluate[evaluator, k_Kernel, t_Transaction] := Module[{list},
    With[{check = CheckSyntax[t["Data"] ]},
        If[! TrueQ[check],
            EventFire[t, "Error", check];
            Return[$Failed];
        ];

        If[! TrueQ[k["ReadyQ"] ],
            EventFire[t, "Error", "Kernel is not ready"];
            Return[$Failed];
        ];

        list = SplitExpression[t["Data"] ];
        MapIndexed[
            With[{message = StringTrim[#1], index = #2[[1]], transaction = Transaction[]},
                If[StringTake[message, -1] === ";", transaction["Nohup"] = True];
                transaction["Data"] = message;
                transaction["Evaluator"] = "JerryI`Notebook`Private`WolframEvaluator";
                
                (* check if it is the last one *)
                If[index === Length[list],
                    EventHandler[transaction // EventClone, {
                        name_ :> Function[data, EventFire[t, name, data] ];
                    }]; 

                    (* capture successfull event of the last transaction to end the process *)
                    EventHandler[transaction // EventClone, {
                        "Result" -> Function[Null, EventFire[t, "Finished", True] ];
                    }];             
                ,
                    EventHandler[transaction, {
                        name_ :> Function[data, EventFire[t, name, data] ];
                    }];                
                ];

                Kernel`Submit[k, transaction];
            ]&
        ,  list];
    ];
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