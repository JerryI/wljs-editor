BeginPackage["Notebook`Utils`Notifications`", {
    "Notebook`Editor`",
    "JerryI`Notebook`", 
    "JerryI`Notebook`Kernel`", 
    "JerryI`Notebook`Evaluator`", 
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

Begin["`Private`"]

(*truncatedTemplate = ImportComponent[ FileNameJoin[{$InputFileName // DirectoryName // ParentDirectory, "templates", "truncated.wlx"}] ];
truncatedTemplate = truncatedTemplate["Data"->"``", "Size"->"``"];*)

EventHandler[NotebookEditorChannel // EventClone,
    {
        "CreateModal" -> Function[data,
            With[{promise = Promise[], backpromise = data["Promise"], modal = data["Modal"], kernel = Kernel`HashMap[ data["Kernel"] ], notebook = Notebook`HashMap[ data["Notebook"] ]},
                With[{

                },
                    

                    Module[{
                        
                    },

                        Echo["Creating modal: "<>modal<>" for channel "<>notebook["ModalsChannel"] ];
                        Echo["Socket: "<>ToString[notebook["Socket"] ] ];

                        EventFire[notebook["ModalsChannel"], modal, Join[data["Data"], <|
                            "Promise"->promise,
                            "Client" -> notebook["Socket"]
                        |>] ];


                        Then[promise, Function[resolve, 
                            ClearAll[proxy];
                            Kernel`Async[kernel, EventFire[backpromise, Resolve, resolve] ];
                        ], Function[reject, 
                            ClearAll[proxy];
                            Kernel`Async[kernel, EventFire[backpromise, Reject, reject] ];
                        ] ];

                    ]
                ]

            
            ]
        ]
    }
]

(*Notify`CreateModal[name_String, data_Association, OptionsPattern[] ] := With[{p = Promise[]},
    EventFire[Internal`Kernel`CommunicationChannel, "CreateModal", <|
            "Notebook"->OptionValue["Notebook"], 
            "Ref"->Global`$EvaluationContext["Ref"], 
            "Promise" -> (promise), 
            "Kernel"->Internal`Kernel`Hash,
            "Modal"->name,
            "Data"->data
    |>];
    
    p
]*)

End[]
EndPackage[]
