BeginPackage["Notebook`Editor`FrontendObject`Sync`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`", 
    "JerryI`Notebook`", 
    "JerryI`WLX`WebUI`", 
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Misc`WLJS`Transport`"
}]

Begin["`Private`"]

rootDir = $InputFileName // DirectoryName // ParentDirectory;

WLJSTransportHandler["GetSymbol"] = Function[{expr, client, callback},
              Print["evaluating cached symbol"];
              With[{name = StringDrop[StringDrop[ToString[expr], StringLength["Hold["] ], -1]},
                If[KeyExistsQ[Notebook`Editor`FrontendObject`Symbols, name],
                    Print[name];
                    callback[Notebook`Editor`FrontendObject`Symbols[name] ]
                ,
                    callback[$Failed]
                ]
              ]
          ];

EventHandler[AppExtensions`AppEvents// EventClone, {
    "Loader:NewNotebook" ->  (Once[ attachListeners[#] ] &),
    "Loader:LoadNotebook" -> (Once[ attachListeners[#] ] &)
}];

attachListeners[notebook_Notebook] := With[{},
    Echo["Attach event listeners to notebook from EXTENSION"];
    EventHandler[notebook // EventClone, {
        "OnBeforeLoad" -> Function[opts,
            If[MemberQ[notebook["Properties"], "Objects"],
                Echo["FrontendObject`Sync >> restored!"];
                Notebook`Editor`FrontendObject`Objects = Join[Notebook`Editor`FrontendObject`Objects, notebook["Objects"] ];
                If[MemberQ[notebook["Properties"], "Symbols"],
                    
                    Notebook`Editor`FrontendObject`Symbols = Join[Notebook`Editor`FrontendObject`Symbols, notebook["Symbols"] ];
                    Echo["FrontendObject`Sync`Symbols >> restored!"];
                ]
            ,
                Echo["FrontendObject`Sync >> nothing to restore "];
            ]
        ],
        "OnBeforeSave" -> Function[opts,
            Echo["OnBefore Save!!!!!!!!"];

            With[{promise = Promise[]},
                Then[WebUIFetch[Global`UIObjects["GetAll"] , opts["Client"] ],
                    Function[pay,
                        Echo["resolved!"];
                        With[{processed = Map[<|"Public"->#|>&, pay]},
                            Notebook`Editor`FrontendObject`Objects = Join[Notebook`Editor`FrontendObject`Objects , processed];
                            notebook["Objects"] = processed;

                            Echo["FrontendObject`Sync`Objects >> ok "];
                            Then[WebUIFetch[Global`UIObjects["GetAllSymbols"] , opts["Client"] ],
                                Function[symbols,
                                    notebook["Symbols"] = symbols;
                                    

                                    Echo["FrontendObject`Sync`Symbols >> ok "];
                                    EventFire[promise, Resolve, True];
                                ]
                            ]
                            
                        ];
                    ]
                , Function[error,
                    Echo["FrontendObject`Sync >> Syncing error!"];
                    Echo[error]
                ] ];

                promise
            ]

        
        ]
    }]; 
]

script = "<script type=\"module\">" <> Import[ FileNameJoin[{rootDir, "templates", "script.js"}], "Text"] <> "</script>";
AppExtensions`TemplateInjection["NotebookScript"] = Function[Null, script];

End[]
EndPackage[]