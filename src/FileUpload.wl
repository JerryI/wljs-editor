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
                    files[name] = payload["Data"] // BaseDecode;
                ];
                count--;
                If[count === 0, 
                    finished;
                    EventRemove[channel];
                ]
            ]
        }];

        finished := With[{path = DirectoryName[ data["Notebook"]["Path"] ]},
            Echo["Uploading files..."];
            (
                With[{filename = FileNameJoin[{path, #}]},
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
        FrontEditorSelected["Set", StringTemplate[" Get[\"``\"] "][ Keys[files] // First ] ]
    ,
        FrontEditorSelected["Set", StringTemplate[" Get /@ `` "][ ToString[Keys[files], InputForm] ] ]
    ], cli]
]

pasteFileNames["md", cli_, files_] := With[{},
    WLJSTransportSend[
        FrontEditorSelected["Set", "\n"<>StringRiffle[StringJoin["![](", URLEncode[#], ")"] &/@ Keys[files], "\n"]<>"\n" ]
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
