BeginPackage["Notebook`CellOperations`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

RemoteCellObj::usage = ""

Begin["`Private`"]

Unprotect[EvaluationCell];
Unprotect[NotebookDirectory];
Unprotect[CellPrint];
Unprotect[ParentCell];

ClearAll[CellPrint]
ClearAll[EvaluationCell]
ClearAll[ParentCell]
ClearAll[NotebookDirectory]

ParentCell[cell_RemoteCellObj:RemoteCellObj[ Global`$EvaluationContext["EvaluationCell"] ] ] := Module[{},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "FindParent", <|"Ref"->Global`$EvaluationContext["Ref"], "CellHash" -> uid, "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] // RemoteCellObj
]

NotebookDirectory[] := With[{},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "AskNotebookDirectory", <|"Ref"->Global`$EvaluationContext["Ref"], "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] 
]

EvaluationCell[] := With[{},
    RemoteCellObj[ Global`$EvaluationContext["EvaluationCell"] ]
]

RemoteCellObj /: EventHandler[ RemoteCellObj[uid_], list_] := With[{virtual = CreateUUID[]},
    EventHandler[virtual, list];
    EventFire[Internal`Kernel`CommunicationChannel, "CellSubscribe", <|"CellHash" -> uid, "Callback" -> virtual, "Kernel"->Internal`Kernel`Hash|>];
]

RemoteCellObj /: Delete[RemoteCellObj[uid_] ] := With[{},
    EventFire[Internal`Kernel`CommunicationChannel, "DeleteCellByHash", uid];
]

CellPrint[str_String, opts___ ] := With[{r = Global`$EvaluationContext["Ref"], hash = CreateUUID[]},
    EventFire[Internal`Kernel`CommunicationChannel, "PrintNewCell", <|"Data" -> str, "Ref"->r, "Meta"-><|"Hash"->hash, "Type"->"Output", "After"->RemoteCellObj[ r ], opts|> |> ];
    RemoteCellObj[hash]
]

End[]
EndPackage[]