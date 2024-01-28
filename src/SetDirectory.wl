BeginPackage["Notebook`Editor`NotebookDirectory`", {
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
    Echo["Attach event listeners to notebook from EXTENSION"];
    EventHandler[notebook // EventClone, {
        "OnWebSocketConnected" -> Function[payload,
            With[{dir = FileNameSplit[ notebook["Path"] // DirectoryName ]},
                Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                    Notebook`DirectorySetter`Private`NotebookDirectoryAppend[dir];
                ] ];
            ];
        ]
    }]; 
]


End[]
EndPackage[]