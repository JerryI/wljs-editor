BeginPackage["Notebook`DirectorySetter`"];

Begin["`Private`"]

NotebookDirectoryAppend[dir_List] := (
    Echo["Append directory to $Path"];
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. AppendNotebookDirectory can only work for on LocalKernel. MasterKernel is not allowed!"];
    ,
        AppendTo[$Path, FileNameJoin[dir] ];
        SetDirectory[ FileNameJoin[dir] ];
    ];
)

End[]

EndPackage[]



