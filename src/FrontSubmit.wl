BeginPackage["Notebook`Editor`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`", 
    "JerryI`Notebook`", 
    "JerryI`Notebook`Windows`",
    "JerryI`WLX`WebUI`", 
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Notebook`Kernel`"
}]

Begin["`Private`"]

rootDir = $InputFileName // DirectoryName // ParentDirectory;

EventHandler[AppExtensions`AppEvents// EventClone, {
    "Loader:NewNotebook" ->  (Once[ attachListeners[#] ] &),
    "Loader:LoadNotebook" -> (Once[ attachListeners[#] ] &)
}];

attachListeners[notebook_Notebook] := With[{},
    Echo["Attach event listeners to notebook from EXTENSION FrontSubmit"];
    EventHandler[notebook // EventClone, {
        "OnWebSocketConnected" -> Function[payload,
            With[{p = Promise[]},
                Echo["Requesting socket object for client..."];
                Then[WebUIFetch[Global`FSAskKernelSocket[], payload["Client"] ], Function[data,
                    notebook["EvaluationContext", "KernelWebSocket"] = data;
                    EventFire[p, Resolve, True];
                ] ];
                p
            ]
        ],

        "OnWindowCreate" -> Function[payload,
            Echo["Subscribe for an window events"];
            With[{win = payload["Window"]},
                EventHandler[win, {
                    "OnWebSocketConnected" -> Function[data,
                        Echo["Requesting socket object for client window object..."];
                        With[{p = Promise[]},
                            Then[WebUIFetch[Global`FSAskKernelSocket[], data["Client"] ], Function[dp,
                                win["EvaluationContext", "KernelWebSocket"] = dp;
                                Echo["Obtained!"];
                                EventFire[p, Resolve, True];
                            ] ];
                            p
                        ]
                    ]
                }];
            ];
        ]
    }]; 
]


End[]
EndPackage[]