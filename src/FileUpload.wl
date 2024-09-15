BeginPackage["Notebook`EditorFileUploader`", {
    "JerryI`Notebook`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Misc`WLJS`Transport`",
    "Notebook`EditorUtilsMinimal`"
}]

Begin["`Private`"]

processRequest[cli_, controls_, data_, __] := With[{channel = data["Channel"]},
    Echo["Drop request >> "];
    Module[{count = data["Length"], files = <||>, finished},
        EventHandler[channel, {
            "File" -> Function[payload,
                With[{name = payload["Name"]},
                    With[{safeName = FileBaseName[name]<>"-"<>StringTake[CreateUUID[], 3]<>"."<>FileExtension[name]},
                        files[safeName] = payload["Data"] // BaseDecode;
                    ]
                ];
                count--;
                If[count === 0, 
                    finished;
                    EventRemove[channel];
                ]
            ]
        }];

        finished := With[{path = DirectoryName[ data["Notebook"]["Path"] ]},
            If[!DirectoryQ[FileNameJoin[{path, "attachments"}] ], CreateDirectory[FileNameJoin[{path, "attachments"}] ] ];
            Echo["Uploading files..."];
            (
                With[{filename = FileNameJoin[{path, "attachments", # }]},
                    BinaryWrite[filename, files[#] ] // Close;
                ]
            ) &/@ Keys[files];
            Echo["Done!"];

            pasteFileNames[data["CellType"], cli, files];
            
        ];
    ];
]

pasteFileNames["wl", cli_, files_] := With[{},
    WLJSTransportSend[If[Length[Keys[files] ] === 1,
        FrontEditorSelected["Set", "Import[FileNameJoin["<>ToString[{"attachments", #} &@ (Keys[files] // First), InputForm]<>"]]" ]
    ,
        FrontEditorSelected["Set", "Import /@ FileNameJoin /@ "<>ToString[ FileNameJoin[{"attachments", #}] &/@ Keys[files], InputForm] ]
    ], cli]
]

pasteFileNames["md", cli_, files_] := With[{},
    WLJSTransportSend[
        FrontEditorSelected["Set", "\n"<>StringRiffle[StringJoin["![](/attachments/", URLEncode[#], ")"] &/@ Keys[files], "\n"]<>"\n" ]
    , cli]
]


(* drop and paste events *)
controlsListener[OptionsPattern[]] := With[{messager = OptionValue["Messanger"], secret = OptionValue["Event"], controls = OptionValue["Controls"], appEvents = OptionValue["AppEvent"], modals = OptionValue["Modals"]},
    EventHandler[EventClone[controls], {
        "CM:DropEvent" -> Function[data, processRequest[Global`$Client, controls, data, modals, messager] ],
        "CM:PasteEvent" -> Function[data, processRequest[Global`$Client, controls, data, modals, messager] ]
    }];

    ""
]

AppExtensions`TemplateInjection["Footer"] = controlsListener;

End[]
EndPackage[]
