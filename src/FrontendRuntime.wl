
BeginPackage["Notebook`Editor`FrontEndRuntime`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`",
    "JerryI`Notebook`",
    "JerryI`Notebook`AppExtensions`"
}]



Begin["`Private`"]

frontEndRuntime = <|
    {"Modules", "js"} -> {},
    {"Modules", "css"} -> {}
|>

rebuild := (
    stringTemplate = {
        StringRiffle[StringJoin["<script type=\"module\">", #, "</script>"] &/@ frontEndRuntime[{"Modules", "js"}] ],
        StringRiffle[StringJoin["<style>", #, "</style>"] &/@ frontEndRuntime[{"Modules", "css"}] ]
    } // StringRiffle;
);

rebuild;

AppExtensions`TemplateInjection["AppHead"] = Function[Null, ""];

injectInRuntime[{"Modules", "js"}, data_List] := With[{notebooks},

]

EventHandler[NotebookEditorChannel // EventClone,
    {
        "RequestRuntimeExtensions" -> Function[assoc,
            With[{result = frontEndRuntime, kernel = assoc["Kernel"], promise = assoc["Promise"]},
                 Kernel`Async[kernel, EventFire[promise, Resolve, result] ];
            ]
        ],

        "UpdateRuntimeExtensions" -> Function[assoc,
            With[{promise = assoc["Promise"], data = assoc["Data"], kernel = assoc["Kernel"], key = assoc["Key"]},

                    With[{new = Complement[data, frontEndRuntime[key] ] // DeleteDuplicates},
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