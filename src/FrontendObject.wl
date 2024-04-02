BeginPackage["Notebook`Editor`FrontendObject`"]

CreateFrontEndObject::usage = "CreateFrontEndObject[expr_, uid_, opts] to force an expression to be evaluated on the frontend inside the container. There are two copies (on Kernel, on Frontend) can be specified using \"Store\"->\"Kernel\", \"Frontend\" or All (by default)"
FrontEndRef::usage = "A readable representation of a stored expression on the kernel"
FrontEndExecutable::usage = "A representation of a stored expression on the frontend"


Begin["`Internal`"]

$MissingHandler[_, _] := $Failed

(* predefine for the future *)
System`WLXForm;

Notebook`Editor`FrontendObject`Objects = <||>

CreateFrontEndObject[expr_, uid_String, OptionsPattern[] ] := With[{},
    With[{
        data = Switch[OptionValue["Store"]
            , "Kernel"
            , <|"Private" -> Hold[expr]|>

            , "Frontend"
            , <|"Public"  -> Hold[expr]|>

            ,_
            , <|"Private" -> Hold[expr], "Public" :> Notebook`Editor`FrontendObject`Objects[uid, "Private"]|>
        ]
    },
        If[KeyExistsQ[Notebook`Editor`FrontendObject`Objects, uid],
            Notebook`Editor`FrontendObject`Objects[uid] = Join[Notebook`Editor`FrontendObject`Objects[uid], data ];    
        ,
            Notebook`Editor`FrontendObject`Objects[uid] = data;    
        ];    
    ];
    
    FrontEndExecutable[uid]
]

CreateFrontEndObject[expr_, opts: OptionsPattern[] ] := CreateFrontEndObject[expr, CreateUUID[], opts]

Options[CreateFrontEndObject] = {"Store" -> All}

FrontEndRef[uid_String] := If[KeyExistsQ[Notebook`Editor`FrontendObject`Objects, uid], 
    Notebook`Editor`FrontendObject`Objects[uid, "Private"] // ReleaseHold
,
    $MissingHandler[uid, "Private"] // ReleaseHold
]

FrontEndExecutable /: MakeBoxes[FrontEndExecutable[uid_String], StandardForm] := RowBox[{"(*VB[*)(FrontEndRef[\"", uid, "\"])(*,*)(*", ToString[Compress[Hold[FrontEndExecutable[uid]]], InputForm], "*)(*]VB*)"}]

Notebook`Editor`FrontendObject`GetObject[uid_String] := With[{},
    (*Echo["Getting object >> "<>uid];*)
    If[KeyExistsQ[Notebook`Editor`FrontendObject`Objects, uid],
        Notebook`Editor`FrontendObject`Objects[uid, "Public"]
    ,
        $Failed
    ]
]

End[]
EndPackage[]