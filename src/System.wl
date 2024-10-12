BeginPackage["Notebook`Editor`System`", {
  "JerryI`Misc`Events`", 
  "JerryI`Misc`Events`Promise`", 
  "Notebook`EditorUtils`",
  "Notebook`Editor`Kernel`FrontSubmitService`"
}]

Begin["`Internal`"]

Unprotect[SystemOpen]
ClearAll[SystemOpen]


getType[str_String] := With[{},
    If[StringMatchQ[str, (LetterCharacter..)~~"://"~~___],
        "URL"
    ,
        If[FileExistsQ[str],
            If[DirectoryQ[str],
                "Folder",
                "File"
            ]
        ,
            $Failed
        ]
    ]
]

SystemOpen::notexist = "File `` does not exist"

SystemOpen[File[path_String], opts: OptionsPattern[] ] := With[{win = OptionValue["Window"], file = {FindFile[File["test.txt"] ]} // Flatten // First},
    If[FailureQ[file],
        Message[SystemOpen::notexist, FileNameTake[path] ];
        $Failed
    ,
        FrontSubmit[SystemOpen[file, "File" ], "Window"->win]
    ]
]

SystemOpen[URL[path_String], opts: OptionsPattern[] ] := With[{win = OptionValue["Window"]},
    FrontSubmit[SystemOpen[path, "URL" ], "Window"->win]
]

SystemOpen[path_String, OptionsPattern[] ] := With[{win = OptionValue["Window"], type = getType[path]},
    If[FailureQ[type],
        Message[SystemOpen::notexist, FileNameTake[path] ];
        $Failed
    ,
        FrontSubmit[SystemOpen[path,  type], "Window"->win]
    ]  
]


Options[SystemOpen] = {"Window" :> CurrentWindow[]}

End[]
EndPackage[]