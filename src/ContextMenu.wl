BeginPackage["Notebook`Editor`ContextMenu`", {
    "JerryI`Notebook`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Transactions`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Misc`WLJS`Transport`",
    "JerryI`WLX`WebUI`",
    "KirillBelov`CSockets`EventsExtension`",
    "Notebook`EditorUtilsMinimal`",
    "CodeParser`"
}]

Begin["`Internal`"]

System`ProvidedOptions;
System`CommentBox;

checkLink[notebook_, logs_] := With[{},
    If[!(notebook["Evaluator"]["Kernel"]["State"] === "Initialized") || !TrueQ[notebook["WebSocketQ"] ],
        EventFire[logs, "Warning", "Kernel is not ready"];
        False
    ,
        True
    ]
]

evaluationInPlace[text_String, notebook_Notebook, controls_, logs_, cli_, head_:""] := Module[{}, With[{p = Promise[], t = Transaction[], k = notebook["Evaluator"]["Kernel"]},
    t["Evaluator"] = Notebook`Editor`WolframEvaluator;
    t["Data"] = StringReplace[StringTrim[text], "%" -> "Global`$$out"];

    With[{check = CheckSyntax[t["Data"] ]},
        Echo[check];
        Echo[t["Data"] ];

        If[! TrueQ[check],
            EventFire[logs, "Warning", check];
            Echo["Syntax Error!"];
            EventFire[p, Reject, $Failed];
            Return[p];
        ];
    ];

    If[StringLength[head] > 0,
        t["Data"] = StringJoin[head,"[",t["Data"],"]"];
    ];


    t["EvaluationContext"] = Join[notebook["EvaluationContext"], <|"Notebook" -> notebook["Hash"]|>];

    EventHandler[t, {
        (* capture successfull event of the last transaction to end the process *)  
        "Result" -> Function[data, 
            EventFire[p, Resolve, data];
        ]
    }];      

    Kernel`Submit[k, t];
    p
] ]

processSelected[text_, notebook_, controls_, logs_, cli_, head_:""] := With[{},
    Echo["Evaluate in PLACE!!!!"];
    If[!checkLink[notebook, logs], Return[] ];
    Then[WebUIFetch[FrontEditorSelected["Get"], cli, "Format"->"JSON"],
        Function[text,
            Then[evaluationInPlace[text, notebook, controls, logs, cli, head], 
                Function[result,
                    WebUISubmit[FrontEditorSelected["Set", result["Data"] ], cli];
                ]
            ,
                Function[result,
                    Echo["Contextmenu >> evaluate in place >> Rejected!"];
                ]
            ];
        ]
    ];
]

processSelected[text_, notebook_, controls_, logs_, cli_, "Store"] := With[{uid = RandomWord[]<>"-"<>StringTake[CreateUUID[], 3]},
    Echo["Evaluate in PLACE!!!!"];
    If[!checkLink[notebook, logs], Return[] ];
    Then[WebUIFetch[FrontEditorSelected["Get"], cli, "Format"->"JSON"],
        Function[text,
            Then[evaluationInPlace[text, notebook, controls, logs, cli, "Function[data, NotebookStore[\""<>uid<>"\"] = data]"], 
                Function[result,
                    WebUISubmit[FrontEditorSelected["Set",  "NotebookStore[\""<>uid<>"\"]"], cli];
                ]
            ,
                Function[result,
                    Echo["Contextmenu >> evaluate in place >> Rejected!"];
                ]
            ];
        ]
    ];
]

addListeners[notebook_Notebook, controls_, logs_, cli_] := With[{},
    EventHandler[controls, {
        "evaluate_in_place" -> Function[Null,
            processSelected[text, notebook, controls, logs, cli]
        ],

        "iconize_selected" -> Function[Null,
            processSelected[text, notebook, controls, logs, cli, "Iconize"]
        ],

        "store_selected" -> Function[Null,
            processSelected[text, notebook, controls, logs, cli, "Store"]
        ],

        "simplify_selected" -> Function[Null,
            processSelected[text, notebook, controls, logs, cli, "Simplify"]
        ],

        "comment_selected" -> Function[Null,
            Then[WebUIFetch[FrontEditorSelected["Get"], cli, "Format"->"JSON"], Function[text,
                With[{trimmed = StringTrim[text]},
                
                    If[StringTake[trimmed, 2] === "(*" && StringTake[trimmed, -2] === "*)",
                        With[{new = StringRiffle[{"(*BB[*)(", StringDrop[StringDrop[trimmed,1],-1], ")(*,*)(*", ToString[Compress[ProvidedOptions[CommentBox["#777"], "String"->True,  "HeadString"->"*", "TailString"->"*"]  ], InputForm], "*)(*]BB*)"}, ""]},
                            WebUISubmit[FrontEditorSelected["Set", new ], cli];
                        ]
                    ,
                        With[{
                            artificial = StringJoin["(*", trimmed, "*)"]
                        },
                            With[{new = StringRiffle[{"(*BB[*)(", StringDrop[StringDrop[artificial,1],-1], ")(*,*)(*", ToString[Compress[ProvidedOptions[CommentBox["#777"], "String"->True,  "HeadString"->"*", "TailString"->"*"]  ], InputForm], "*)(*]BB*)"}, ""]},
                                WebUISubmit[FrontEditorSelected["Set", new ], cli];
                            ]                        
                        ]
                    ]
                ]
            ] ];
        ],

        "highlight_selected" -> Function[Null,
            Then[WebUIFetch[FrontEditorSelected["Get"], cli, "Format"->"JSON"], Function[text,
                With[{new = StringRiffle[{"(*BB[*)(", text, ")(*,*)(*", ToString[Compress[Hold[StyleBox[Background->RGBColor[1.,1.,0.] ] ] ], InputForm], "*)(*]BB*)"}, ""]},
                    WebUISubmit[FrontEditorSelected["Set", new ], cli];
                ]
            ] ];
        ]                 
    }];
]

sniffer[ OptionsPattern[] ] := With[{logs = OptionValue["Messager"], notebook = OptionValue["Notebook"], controls = OptionValue["Controls"] // EventClone, event = OptionValue["Event"] // EventClone},
    EventHandler[event, {
        "Load" -> Function[Null,
            addListeners[notebook, controls, logs, Global`$Client];
            With[{cloned = EventClone[Global`$Client]},
      
                EventHandler[cloned, {
                    "Closed" -> Function[Null,
                        Echo["Context menu listener was destroyed"];
                        EventRemove[controls];
                        EventRemove[event];
                        EventRemove[cloned];
                    ]
                }]
            ];
        ]
    }];
    (* nothing to display *)
    ""
]

AppExtensions`TemplateInjection["Footer"] = sniffer;


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