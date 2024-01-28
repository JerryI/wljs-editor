BeginPackage["Notebook`Editor`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`", 
    "JerryI`Notebook`", 
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
            Echo["Requesting socket object for client..."];
            Then[WebUIFetch[Global`FSAskKernelSocket[], payload["Client"] ], Function[data,
                notebook["EvaluationContext", "KernelWebSocket"] = data;
            ] ];
        ]
    }]; 
]


End[]
EndPackage[]