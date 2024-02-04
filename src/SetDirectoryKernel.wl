BeginPackage["Notebook`DirectorySetter`", {"JerryI`Misc`Events`"}];

Begin["`Private`"]

EventHandler["KernelDir", Function[path,
    Echo["Settings kernel's directory..."];
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. RemoveNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        SetDirectory[ path // URLDecode ];
    ];    
] ];

NotebookDirectoryAppend[dir_List] := (
    Echo["Append directory to $Path"];
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. AppendNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        AppendTo[$Path, FileNameJoin[dir] ];
        SetDirectory[ FileNameJoin[dir] ];
    ];
)

NotebookDirectoryRemove[dir_List] := (
    Echo["Remove directory from $Path"];
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. RemoveNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        $Path = $Path /. {FileNameJoin[dir] -> Nothing};
    ];
)

End[]

EndPackage[]



