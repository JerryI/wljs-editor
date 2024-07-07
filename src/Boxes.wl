BeginPackage["Notebook`Editor`Boxes`", {
  "JerryI`Misc`Events`", 
  "Notebook`Editor`FrontendObject`",
  "Notebook`EditorUtils`"
}]

System`ViewBox;
System`BoxBox;

ViewBox::usage = "ViewBox[expr_, decorator_] low-level box used by InterpretationBox. It keeps `expr` in its original form, while visially covers it with DOM element to which `decorator` expression will be attached and executed"
ViewBox`InnerExpression::usage = "ViewBox`InnerExpression[expr_] sets content of a view box being evaluated inside the container (see MetaMarker)"
ViewBox`OuterExpression::usage = "ViewBox`OuterExpression[expr_] sets content of a th whole view box being evaluated inside the container (see MetaMarker)"

BoxBox::usage = "BoxBox[expr_Box | _String, decorator_, opts___] low-level box used by Style, Framed... It places a subeditor with `expr` inside and decorates the container using `decorator` expression will be attached and executed. \"Head\" is an option for inserting the head"


Begin["`Private`"]

System`ProvidedOptions;

ViewBox[expr_, display_, OptionsPattern[] ] := With[{event = OptionValue["Event"]}, If[event === Null,
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[display] ], InputForm], "*)(*]VB*)"}]
,
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[ProvidedOptions[Hold[display], "Event"->event ] ], InputForm], "*)(*]VB*)"}]
] ]

Options[ViewBox] = {"Event" -> Null}

notString[s_] := !StringQ[s]
ViewBox`InnerExpression[s_?notString] := ViewBox`InnerExpression[ ToString[s, StandardForm] ]

ViewBox`OuterExpression[s_?notString] := ViewBox`OuterExpression[ ToString[s, StandardForm] ]


(*TODO: MAKE IT JUST OPTIONS REMOVE IFs !!! *)
BoxBox[expr_, display_, OptionsPattern[] ] := With[{event = OptionValue["Event"]}, 
  If[OptionValue[Head] =!= Null,
    With[{dp = ProvidedOptions[Hold[display], "Head"->ToString[OptionValue[Head], InputForm], "Event"->event]},
      RowBox[{"(*BB[*)(", ToString[OptionValue[Head], InputForm], "[", expr, "]", ")(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]
    ]
  ,
    If[OptionValue["String"] === True,
      With[{dp = ProvidedOptions[Hold[display], "String"->True, "Event"->event]},
        RowBox[{"(*BB[*)(", expr, ")(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]
      ]
    ,
      If[event === Null,
        RowBox[{"(*BB[*)(", expr, ")(*,*)(*", ToString[Compress[Hold[display] ], InputForm], "*)(*]BB*)"}]
      ,
        With[{dp = ProvidedOptions[Hold[display], "Event"->event]},
          RowBox[{"(*BB[*)(", expr, ")(*,*)(*", ToString[Compress[Hold[dp] ], InputForm], "*)(*]BB*)"}]
        ]
      ]
    ]
  ]
]


Options[BoxBox] = {Head -> Null, "String"->False, "Event"->Null}




End[]
EndPackage[]