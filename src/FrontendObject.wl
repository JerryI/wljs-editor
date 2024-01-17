Begin["Notebook`Editor`FrontendObject`"]

Notebook`Editor`FrontendObject`Objects = <||>

Global`CreateFrontEndObject[expr_] := With[{uid = CreateUUID[]},
    Echo["Create frontend object with uid: "<>uid];
    Notebook`Editor`FrontendObject`Objects[uid] = <|"Private" -> Hold[expr], "Public" :> Notebook`Editor`FrontendObject`Objects[uid, "Private"]|>;
    Global`FrontEndExecutable[uid]
]

Global`CreateFrontEndObject[expr_, uid_String] := With[{},
    Echo["Create frontend object with uid: "<>uid];
    Notebook`Editor`FrontendObject`Objects[uid] = <|"Private" -> Hold[expr], "Public" :> Notebook`Editor`FrontendObject`Objects[uid, "Private"]|>;
    Global`FrontEndExecutable[uid]
]

FrontEndRef[uid_String] := Notebook`Editor`FrontendObject`Objects[uid, "Private"] // ReleaseHold

Global`FrontEndExecutable /: MakeBoxes[Global`FrontEndExecutable[uid_String], StandardForm] := RowBox[{"(*VB[*)(FrontEndRef[\"", uid, "\"])(*,*)(*", ToString[Compress[Hold[Global`FrontEndExecutable[uid]]], InputForm], "*)(*]VB*)"}]

Notebook`Editor`FrontendObject`GetObject[uid_String] := With[{},
    Echo["Getting object >> "<>uid];
    If[KeyExistsQ[Notebook`Editor`FrontendObject`Objects, uid],
        Notebook`Editor`FrontendObject`Objects[uid, "Public"]
    ,
        $Failed
    ]
]

End[]