
BeginPackage["Notebook`Editor`FrontEndRuntime`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`",
    "JerryI`Notebook`Kernel`",
    "JerryI`Notebook`",
    "JerryI`Notebook`AppExtensions`",
    "Notebook`Editor`",
    "JerryI`WLX`WebUI`"  
}]



Begin["`Private`"]

frontEndRuntime = <|
    {"Modules", "js"} -> {},
    {"Modules", "css"} -> {}
|>

rebuild := (
    compiledString = {
        StringRiffle[StringJoin["<script type=\"module\">", #, "</script>"] &/@ frontEndRuntime[{"Modules", "js"}] ],
        StringRiffle[StringJoin["<style>", #, "</style>"] &/@ frontEndRuntime[{"Modules", "css"}] ]
    } // StringRiffle;
);

rebuild;

component[__] := compiledString

AppExtensions`TemplateInjection["AppHead"] = component

injectInRuntime[{"Modules", "js"}, data_List] := With[{notebooks = Values[Notebook`HashMap]},
    WebUISubmit[ Global`UIHeadInject["js", data ], #["Socket"] ] &/@ notebooks;
]

EventHandler[NotebookEditorChannel // EventClone,
    {
        "RequestRuntimeExtensions" -> Function[assoc,
            With[{result = frontEndRuntime, kernel = Kernel`HashMap[assoc["Kernel"] ], promise = assoc["Promise"]},
                 Kernel`Async[kernel, EventFire[promise, Resolve, result] ];
            ]
        ],

        "UpdateRuntimeExtensions" -> Function[assoc,
            With[{promise = assoc["Promise"], data = assoc["Data"], kernel = Kernel`HashMap[assoc["Kernel"] ], key = assoc["Key"]},

                    With[{new = Complement[data, frontEndRuntime[key] // DeleteDuplicates ] // DeleteDuplicates},
                        frontEndRuntime[key] = data // DeleteDuplicates;
                        injectInRuntime[key, new];
                    ];

                rebuild;
                Pause[0.3];
                Kernel`Async[kernel, EventFire[promise, Resolve, True] ];
            ]
        ]

    }
]

End[]
EndPackage[]