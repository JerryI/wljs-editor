BeginPackage["Notebook`Editor`FrontendObject`Sync`", {"JerryI`Misc`Events`","JerryI`Misc`Events`Promise`", "JerryI`Notebook`", "JerryI`WLX`WebUI`", "JerryI`Notebook`AppExtensions`"}]

Begin["`Private`"]

rootDir = $InputFileName // DirectoryName // ParentDirectory;

EventHandler[AppExtensions`AppEvents// EventClone, {
    "Loader:NewNotebook" ->  (Once[ attachListeners[#] ] &),
    "Loader:LoadNotebook" -> (Once[ attachListeners[#] ] &)
}];


attachListeners[notebook_Notebook] := With[{},
    Echo["Attach event listeners to notebook from EXTENSION"];
    EventHandler[notebook, {
        "OnBeforeLoad" -> Function[opts,
            If[MemberQ[notebook["Properties"], "Objects"],
                Echo["FrontendObject`Sync >> restored!"];
                Notebook`Editor`FrontendObject`Objects = Join[Notebook`Editor`FrontendObject`Objects, notebook["Objects"] ];
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

                            Echo["FrontendObject`Sync >> ok "];
                            EventFire[promise, Resolve, True];
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