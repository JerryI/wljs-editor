BeginPackage["Notebook`Editor`NotebookStorage`", {
    "Notebook`Editor`",
    "JerryI`Notebook`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

Begin["`Internal`"]


EventHandler[NotebookEditorChannel // EventClone,
    {
        "NotebookStoreGetKeys" -> Function[data,
           With[{promise = data["Promise"], notebook = Notebook`HashMap[ data["Ref"] ], kernel = Kernel`HashMap[ data["Kernel"] ]},
                If[!MemberQ[notebook["Properties"], "Storage"],
                    notebook["Storage"] = <||>;
                ];

                With[{keys = notebook["Storage"] // Keys},
                    Kernel`Async[kernel, EventFire[promise, Resolve, keys] ];
                ];
           ];
        ],

        "NotebookStoreGet" -> Function[data,
           With[{promise = data["Promise"], notebook = Notebook`HashMap[ data["Ref"] ], kernel = Kernel`HashMap[ data["Kernel"] ]},
                With[{value = notebook["Storage", data["Key"] ]},
                    Kernel`Async[kernel, EventFire[promise, Resolve, value] ];
                ];
           ];
        ],

        "NotebookStoreSet" -> Function[data,
           With[{promise = data["Promise"], payload = data["Data"], notebook = Notebook`HashMap[ data["Ref"] ], kernel = Kernel`HashMap[ data["Kernel"] ]},
                If[!MemberQ[notebook["Properties"], "Storage"],
                    notebook["Storage"] = <||>;
                ];

                notebook["Storage"] = Join[notebook["Storage"], <|data["Key"] -> payload|>];
                
                With[{value = data["Key"]},
                    Kernel`Async[kernel, EventFire[promise, Resolve, value] ];
                ];
           ];
        ],

        "NotebookStoreUnset" -> Function[data,
           With[{promise = data["Promise"], key = data["Key"], notebook = Notebook`HashMap[ data["Ref"] ], kernel = Kernel`HashMap[ data["Kernel"] ]},
                If[!MemberQ[notebook["Properties"], "Storage"],
                    notebook["Storage"] = <||>;
                ];

                notebook["Storage"] = KeyDrop[notebook["Storage"], key];
                
                With[{value = data["Key"]},
                    Kernel`Async[kernel, EventFire[promise, Resolve, value] ];
                ];
           ];
        ]              
    }
]

End[]
EndPackage[]