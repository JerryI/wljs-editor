BeginPackage["Notebook`Editor`NotebookDirectory`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`", 
    "JerryI`Notebook`", 
    "JerryI`WLX`WebUI`", 
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Notebook`Kernel`"
}]

SetKernelDirectory::usage="";

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
                Echo[">> set directory (forced)"];
                Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                        Notebook`DirectorySetter`Private`NotebookDirectorySet[dir];
                ] ];
            ];
            (*With[{dir = FileNameSplit[ notebook["Path"] // DirectoryName ]},
                Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                    Notebook`DirectorySetter`Private`NotebookDirectoryAppend[dir];
                ] ];
            ];*)
            (*With[{dir = FileNameSplit[ notebook["Path"] // DirectoryName ]},
                WebUISubmit[SetKernelDirectory[dir // FileNameJoin // URLEncode, "KernelDir"], payload["Client"] ]
            ];*) 
        ],
        "OnBeforeLoad" -> Function[payload,
            With[{dir = FileNameSplit[ notebook["Path"] // DirectoryName ]},
                WebUISubmit[SetKernelDirectory[dir // FileNameJoin // URLEncode, "KernelDir"], payload["Client"] ];
            ];       
        ],
        "OnClose" -> Function[payload,
            Print[""];
            (*With[{dir = FileNameSplit[ notebook["Path"] // DirectoryName ]},
                Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                    Notebook`DirectorySetter`Private`NotebookDirectoryRemove[dir];
                ] ];
            ];*)            
        ]
    }]; 
]


End[]
EndPackage[]