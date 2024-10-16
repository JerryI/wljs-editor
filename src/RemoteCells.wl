BeginPackage["Notebook`Editor`RemoteCells`", {
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
        "DeleteCellByHash" -> Function[uid,
            Echo["Delete object "<>uid];
            Delete[ CellObj`HashMap[uid] ]
        ],

        "SetCellData" -> Function[assoc,
         
            With[{cell = CellObj`HashMap[assoc["Hash"] ]},
                Print["Updating the content: "];
                Print[cell];

                EventFire[cell, "ChangeContent", assoc["Data"] ];
                (*no need in setting also in an object, it will be done for the feedback from CM6 editor*)
            ]
        ],

        "AskNotebookDirectory" -> Function[data,
           With[{promise = data["Promise"], kernel = Kernel`HashMap[ data["Kernel"] ]},
            
                With[{ref = data["Ref"]},
                        If[ !MissingQ[CellObj`HashMap[ref] ] ,
                            With[{dir = If[DirectoryQ[#], #, DirectoryName[#] ] &@ (CellObj`HashMap[ref]["Notebook"]["Path"])},
                                If[StringQ[dir],
                                    Kernel`Async[kernel, EventFire[promise, Resolve, dir] ];
                                ,
                                    Echo["RemoveCells >> Error. path is not a string! "];
                                    Echo[dir];
                                ]
        
                                
                            ];
                        ,
                            Echo["RemoveCells >> Error. not found reference cell"];
                        ];
                ]
 
            ];
        ],

        "FindParent" -> Function[data,
            With[{promise = data["Promise"], o = CellObj`HashMap[ data["CellHash"] ], kernel = Kernel`HashMap[ data["Kernel"] ]},

                If[MissingQ[o],
                    Echo["RemoveCells >> cell does not exist. Using reference cell instead"];
                    With[{ref = data["Ref"]},
                        If[ !MissingQ[CellObj`HashMap[ref] ] ,
                            Echo["RemoveCells >> "<>ToString[ref] ];
                            Kernel`Async[kernel, EventFire[promise, Resolve, ref] ];
                        ,
                            Echo["RemoveCells >> Error. not found"];
                        ];
                    ]
                ,
                    With[{parent = (SequenceCases[o["Notebook"]["Cells"], {_?InputCellQ, ___?OutputCellQ, o} ] // First // First)["Hash"]},
                        Echo["RemoteCells >> found parent"];
                        Echo[parent];
                        
                        Kernel`Async[kernel, EventFire[promise, Resolve, parent] ];
                    ]                 
                ];
 
            ];
        ],

        "PrintNewCell" -> Function[t,
            Print["!!!!!"];
            With[{reference = CellObj`HashMap[ t["Ref"] ]},
                Echo[reference];
                CellObj @@ Join[{"Notebook" -> reference["Notebook"], "Data" -> t["Data"]}, 
                    ReplaceAll[ 
                        Normal[t["Meta"] ] 
                    , {Notebook`CellOperations`RemoteCellObj -> CellObj`HashMap}] 
                ];
            ]
        ],

        "CellSubscribe" -> Function[assoc,
            Print["CellSubscribe!!!!!!"];
            With[{hash = assoc["CellHash"], callback = assoc["Callback"], kernel = Kernel`HashMap[ assoc["Kernel"] ]},
                EventHandler[EventClone[hash], {
                    any_String :> Function[data,
                        Kernel`Async[kernel, EventFire[callback, any, data] ];
                    ]
                }]
            ]
        ],
        
        (* FIXME!!! NOT EFFICIENT!*)
        (* DO NOT USE BLANK PATTERN !!! *)
        "NotebookSubscribe" -> Function[assoc,
            Print["NotebookSubscribe!!!!!!"];
            With[{hash = assoc["NotebookHash"], callback = assoc["Callback"], kernel = Kernel`HashMap[ assoc["Kernel"] ]},
                EventHandler[EventClone[hash], {
                    any_String :> Function[data,
                        Kernel`Async[kernel, EventFire[callback, any, data] ];
                    ]
                }]
            ]
        ],


        "NotebookFieldSet" -> Function[assoc,
            With[{notebook = Notebook`HashMap[ assoc["NotebookHash"] ], field = assoc["Field"], value = assoc["Value"]},
                notebook[field] = value
            ]
        ]      
    }
]

End[]
EndPackage[]