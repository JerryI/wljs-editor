BeginPackage["Notebook`CellOperations`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

RemoteCellObj::usage = "Internal representation of remote cell object on Kernel"
RemoteNotebook::usage = "Internal representation of remote notebook object on Kernel"

ResultCell::usage = "An access to an output cell generated during the evaluation"

Begin["`Private`"]

Unprotect[EvaluationCell];
Unprotect[EvaluationNotebook];
Unprotect[NotebookDirectory];
Unprotect[CellPrint];
Unprotect[ParentCell];

ClearAll[CellPrint]
ClearAll[EvaluationNotebook]
ClearAll[EvaluationCell]
ClearAll[ParentCell]
ClearAll[NotebookDirectory]

ParentCell[cell_RemoteCellObj: RemoteCellObj[ Global`$EvaluationContext["ResultCellHash"] ] ] := Module[{},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "FindParent", <|"Ref"->Global`$EvaluationContext["Ref"], "CellHash" -> (cell // First), "Promise" -> (promise), "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] // RemoteCellObj
]

NotebookDirectory[] := With[{},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "AskNotebookDirectory", <|"Ref"->Global`$EvaluationContext["Ref"], "Promise" -> (promise), "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] 
]

EvaluationCell[] := With[{},
    RemoteCellObj[ Global`$EvaluationContext["Ref"] ]
]

ResultCell[] := With[{},
    RemoteCellObj[ Global`$EvaluationContext["ResultCellHash"] ]
]

EvaluationNotebook[] := With[{},
    RemoteNotebook[ Global`$EvaluationContext["Notebook"] ]
]

RemoteNotebook /: Set[RemoteNotebook[uid_][field_], value_] := With[{},
    EventFire[Internal`Kernel`CommunicationChannel, "NotebookFieldSet", <|"NotebookHash" -> uid, "Field" -> field, "Value"->value, "Kernel"->Internal`Kernel`Hash|>];
    Null;
]


(* FIXME!!! NOT EFFICIENT!*)
(* DO NOT USE BLANK PATTERN !!! *)
RemoteNotebook /: EventHandler[ RemoteNotebook[uid_], list_] := With[{virtual = CreateUUID[]},
    EventHandler[virtual, list];
    EventFire[Internal`Kernel`CommunicationChannel, "NotebookSubscribe", <|"NotebookHash" -> uid, "Callback" -> virtual, "Kernel"->Internal`Kernel`Hash|>];
]

(* FIXME!!! NOT EFFICIENT!*)
RemoteNotebook /: EventClone[ RemoteNotebook[uid_] ] := With[{virtual = CreateUUID[], cloned = CreateUUID[]},
    EventHandler[virtual, {
        any_ :> Function[payload,
            EventFire[cloned, any, payload]
        ]
    }];
    EventFire[Internal`Kernel`CommunicationChannel, "NotebookSubscribe", <|"NotebookHash" -> uid, "Callback" -> virtual, "Kernel"->Internal`Kernel`Hash|>];
    
    EventObject[<|"Id"->cloned|>]
]

RemoteCellObj /: EventHandler[ RemoteCellObj[uid_], list_] := With[{virtual = CreateUUID[]},
    EventHandler[virtual, list];
    EventFire[Internal`Kernel`CommunicationChannel, "CellSubscribe", <|"CellHash" -> uid, "Callback" -> virtual, "Kernel"->Internal`Kernel`Hash|>];
]

RemoteCellObj /: Delete[RemoteCellObj[uid_] ] := With[{},
    EventFire[Internal`Kernel`CommunicationChannel, "DeleteCellByHash", uid];
]

RemoteCellObj /: Set[RemoteCellObj[uid_]["Data"], data_String ] := With[{},
    EventFire[Internal`Kernel`CommunicationChannel, "SetCellData", <|"Hash"->uid, "Data"->data|>];
]

CellPrint[str_String, opts___] := With[{hash = CreateUUID[], list = Association[opts]},
    If[AssociationQ[Global`$EvaluationContext],
        With[{r = Global`$EvaluationContext["Ref"]},
            EventFire[Internal`Kernel`CommunicationChannel, "PrintNewCell", <|"Data" -> str, "Ref"->r, "Meta"-><|"Hash"->hash, "Type"->"Output", "After"->RemoteCellObj[ r ], opts|> |> ];
        ];
    ,
        With[{r = list["After"] // First},
            EventFire[Internal`Kernel`CommunicationChannel, "PrintNewCell", <|"Data" -> str, "Ref"->r, "Meta"-><|"Hash"->hash, "Type"->"Output", "After"->RemoteCellObj[ r ], opts|> |> ];
        ];    
    ];

    RemoteCellObj[hash]
]

Options[CellPrint] = {}

End[]
EndPackage[]