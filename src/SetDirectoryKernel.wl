BeginPackage["Notebook`DirectorySetter`", {
    "JerryI`Misc`Events`"
}]

Begin["`Private`"]

EventHandler["KernelDir", Function[path,
   
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. RemoveNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        SetDirectory[ path // URLDecode ];
    ];    
] ];

NotebookDirectorySet[dir_List] := (
    SetDirectory[ dir // FileNameJoin ];
)

  (*NotebookDirectoryAppend[dir_List] := (
   skip this ...

    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. AppendNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        AppendTo[$Path, FileNameJoin[dir] ];
        SetDirectory[ FileNameJoin[dir] ];
    ];*)
(*

NotebookDirectoryRemove[dir_List] := (
    (*Echo["Remove directory from $Path"];*)
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. RemoveNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        $Path = $Path /. {FileNameJoin[dir] -> Nothing};
    ];
) *)

End[]

EndPackage[]



