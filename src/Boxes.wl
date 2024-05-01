Unprotect[FractionBox]
FractionBox[a_, b_] := RowBox[{"(*FB[*)((", a, ")(*,*)/(*,*)(", b, "))(*]FB*)"}]

Unprotect[SqrtBox]
SqrtBox[a_] := RowBox[{"(*SqB[*)Sqrt[", a, "](*]SqB*)"}]

Unprotect[SuperscriptBox]
SuperscriptBox[a_, b_] := RowBox[{"(*SpB[*)Power[", a, "(*|*),(*|*)",  b, "](*]SpB*)"}]
SuperscriptBox[a_, b_, _] := RowBox[{"(*SpB[*)Power[", a, "(*|*),(*|*)",  b, "](*]SpB*)"}]

Unprotect[SubscriptBox]
SubscriptBox[a_, b_] := RowBox[{"(*SbB[*)Subscript[", a, "(*|*),(*|*)",  b, "](*]SbB*)"}]
SubscriptBox[a_, b_, _] := RowBox[{"(*SbB[*)Subscript[", a, "(*|*),(*|*)",  b, "](*]SbB*)"}]

Unprotect[GridBox]
GridBox[list_List, a___] := RowBox@(Join@@(Join[{{"(*GB[*){"}}, Riffle[#, {{"(*||*),(*||*)"}}] &@ (Join[{"{"}, Riffle[#, "(*|*),(*|*)"], {"}"}] &/@ list), {{"}(*]GB*)"}}]))

Unprotect[TagBox]
TagBox[x_, opts___] := x

TagBox["ByteArray", "SummaryHead"] = ""

(* FIX for WL14 *)
TagBox[any_, f_Function] := any

Unprotect[FrameBox]
FrameBox[x_, opts__]  := RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[FrameBox[opts]]], InputForm], "*)(*]BB*)"}]

Unprotect[StyleBox]
StyleBox[x_, opts__]  := RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[StyleBox[opts]]], InputForm], "*)(*]BB*)"}]

(*if a string, then remove quotes*)
Unprotect[Style]
Style /: MakeBoxes[Style[s_String, opts__], StandardForm] := StringBox[s, opts]
StringBox[x_String, opts__]  := RowBox[{"(*BB[*)(", ToString[x, InputForm], ")(*,*)(*", ToString[Compress[ProvidedOptions[Hold[StringBox[opts] ], "String"->True ] ], InputForm], "*)(*]BB*)"}, "String"->True]


Unprotect[PanelBox]
PanelBox[x_, opts__]  := RowBox[{"(*BB[*)(Panel[", x, "])(*,*)(*", ToString[Compress[Hold[ProvidedOptions[PanelBox[opts], "Head"->"Panel"]]], InputForm], "*)(*]BB*)"}]

iHighlight[expr_] := Style[expr, Background->Yellow]

Unprotect[TemplateBox]

TemplateBox[list_List, "RowDefault"] := GridBox[{list}]

TemplateBox[{n_, short_String, _, units_String}, "Quantity", ___] := RowBox[{"(*VB[*)(", StringTemplate["Quantity[``, ``]"][n, units], ")(*,*)(*", ToString[Compress[ QuantityBox[n, StringDrop[StringDrop[short, -1], 1] ] ], InputForm], "*)(*]VB*)"}]

TemplateBox[{number_}, "C"] := RowBox[{ SubscriptBox[C, number]}]

TemplateBox[expr_, "Bra"] := With[{dp = ProvidedOptions[BraDecorator, "Head"->"Bra"]}, RowBox[{"(*BB[*)(Bra[", RowBox[Riffle[expr, ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]
TemplateBox[expr_, "Ket"] := With[{dp = ProvidedOptions[KetDecorator, "Head"->"Ket"]}, RowBox[{"(*BB[*)(Ket[", RowBox[Riffle[expr, ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

Unprotect[Ket]
Unprotect[Bra]

Ket /: MakeBoxes[Ket[list__], StandardForm] := With[{dp = ProvidedOptions[KetDecorator, "Head"->"Ket"]}, RowBox[{"(*BB[*)(Ket[", RowBox[Riffle[List[list], ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

Bra /: MakeBoxes[Bra[list__], StandardForm] := With[{dp = ProvidedOptions[BraDecorator, "Head"->"Bra"]}, RowBox[{"(*BB[*)(Bra[", RowBox[Riffle[List[list], ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

Unprotect[DynamicModuleBox]
(* fallback *)
DynamicModuleBox[vars_, body_] := body

TemplateBox[assoc_Association, "RGBColorSwatchTemplate"] := With[{color = assoc["color"]//N},
   RowBox[{"(*VB[*)(", ToString[assoc["color"], InputForm], ")(*,*)(*", ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[expr_List, "DateObject", __] := With[{date = expr[[1]][[1]][[1]]},
   RowBox[{"(*VB[*)(", expr[[2]], ")(*,*)(*", ToString[Compress[Hold[DateObjectTemplate[date]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[expr_List, "SummaryPanel"] := RowBox[expr]



(*internal*)
ViewBox[expr_, display_, OptionsPattern[] ] := With[{event = OptionValue["Event"]}, If[event === Null,
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[display] ], InputForm], "*)(*]VB*)"}]
,
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[ProvidedOptions[Hold[display], "Event"->event ] ], InputForm], "*)(*]VB*)"}]
] ]

Options[ViewBox] = {"Event" -> Null}

Unprotect[Iconize]
ClearAll[Iconize]

Iconize[expr_, opts: OptionsPattern[] ] := With[{},
  If[ByteCount[expr] > 30000,
    With[{name = "iconized-"<>StringTake[CreateUUID[], 4]<>".wl"},
      If[!DirectoryQ[".iconized"],  CreateDirectory[FileNameJoin[{Directory[], ".iconized"}] ]  ];
      Put[expr, FileNameJoin[{".iconized", name}] ];
      IconizedFile[{".iconized", name}, ByteCount[expr], opts]
    ]
  ,
    Iconized[expr // Compress, ByteCount[expr], opts]
  ]
]

Iconize[expr_, title_String] := With[{},
  If[ByteCount[expr] > 30000,
    With[{name = title<>"-"<>StringTake[CreateUUID[], 4]<>".wl"},
      If[!DirectoryQ[".iconized"],  CreateDirectory[FileNameJoin[{Directory[], ".iconized"}] ]  ];
      Put[expr, FileNameJoin[{".iconized", name}] ];
      IconizedFile[{".iconized", name}, ByteCount[expr] ]
    ]
  ,
    Iconized[expr // Compress, ByteCount[expr] ]
  ]
]

Options[Iconize] = {"Label"->None}


IconizedFile /: MakeBoxes[IconizedFile[c_, b_, opts___], StandardForm] := RowBox[{"(*VB[*)(Get[FileNameJoin[", ToString[c, InputForm], "]])(*,*)(*", ToString[Compress[Hold[IconizeFileBox[b, opts] ] ], InputForm], "*)(*]VB*)"}]
Iconized /: MakeBoxes[Iconized[c_, b_, opts___], StandardForm] := RowBox[{"(*VB[*)(Uncompress[", ToString[c, InputForm], "])(*,*)(*", ToString[Compress[Hold[IconizeBox[b, opts] ] ], InputForm], "*)(*]VB*)"}]

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

Unprotect[PaneSelectorBox]

PaneSelectorBox[list_, opts___] := list[[1]][[2]]

Unprotect[InterpretationBox]

(* ToString[, InputForm] is IMPORTANT!!! *)

InterpretationBox[placeholder_, expr_, opts___] := With[{data = expr, v = EditorView[ToString[placeholder /. {RowBox->RowBoxFlatten}], ReadOnly->True]},
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[v]], InputForm], "*)(*]VB*)"}]
]

Unprotect[Interpretation]

Interpretation[view_FrontEndExecutable, expr_] := With[{},
  (*Echo["Optimized expression!"];*)
  InterpretationOptimized[view, expr]
]

InterpretationOptimized /: MakeBoxes[InterpretationOptimized[view_, expr_], StandardForm] := RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[view]], InputForm], "*)(*]VB*)"}]




TemplateBox[v_List, "SummaryPanel"] := v

EventObjectHasView[assoc_Association] := KeyExistsQ[assoc, "View"]
EventObject /: MakeBoxes[EventObject[a_?EventObjectHasView], StandardForm] := If[StringQ[a["View"] ],
  (* reuse an existing FE Object to save up resources, if someone copied it *)
  With[{uid = a["View"]}, 
    RowBox[{"(*VB[*)(", ToString[EventObject[Join[a, <|"View"->uid|>] ], InputForm], ")(*,*)(*", ToString[Compress[Hold[FrontEndExecutable[uid]]], InputForm], "*)(*]VB*)"}]
  ]
,
  With[{uid = CreateFrontEndObject[a["View"] ] // First}, 
    RowBox[{"(*VB[*)(", ToString[EventObject[Join[a, <|"View"->uid|>] ], InputForm], ")(*,*)(*", ToString[Compress[Hold[FrontEndExecutable[uid]]], InputForm], "*)(*]VB*)"}]
  ] 
]


(* Legends workaround *)
Unprotect[Legended]

Internal`RawText /: MakeBoxes[Internal`RawText[text_String], StandardForm] := ViewBox[text, Hold[Internal`RawText[text]]]

Internal`RawText /: MakeBoxes[Internal`RawText[text_], StandardForm] := MakeBoxes[text, StandardForm]

Unprotect[FrameBox]
FrameBox[x_] := FrameBox[x, "Background"->White] 

(* TODO: just leave as EditorView, no ToStringMethod *)
(* Assume that EditorView will automatically apply ToString *)

Legended[expr_, SwatchLegend[l_List, names_List] ] := ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject

Legended[expr_, {Placed[SwatchLegend[l_, names_List, opts__], _, Identity]}] := ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject

Legended[expr_, Placed[SwatchLegend[l_, names_List, opts__], _, Identity] ] := ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject

Legended[expr_, {Placed[LineLegend[l_, names_List, opts__], _, Identity]}] := ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject

Legended[expr_, Placed[LineLegend[l_, names_List, opts__], _, Identity] ] := ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject




Unprotect[BoxForm`ArrangeSummaryBox]
ClearAll[BoxForm`ArrangeSummaryBox]

Unprotect[BoxForm`SummaryItem]

BoxForm`SummaryItem[{label_String, view_}] := BoxForm`SummaryItemView[label, EditorView[ToString[view, StandardForm], "ReadyOnly"->True]]

BoxForm`IconsStore = <||>;

BoxForm`temporal = {};

Options[BoxForm`ArrangeSummaryBox] = {"Event" -> Null}

BoxForm`ArrangeSummaryBox[head_, interpretation_, icon_, above_, hidden_, ___, OptionsPattern[] ] := With[{
  headString = ToString[head, InputForm],
  event = OptionValue["Event"],
  iconHash = Hash[icon]
},

  (* Wolfram cleans up icon symbols for some reason. Frontend cannot get them back. Also to fix this and improve caching we will store the copies of them separately *)
  With[{iconSymbol = If[KeyExistsQ[BoxForm`IconsStore, iconHash], 
                      BoxForm`IconsStore[iconHash]
                    ,
                      Module[{iconTempSymbol},
                        If[icon === None, Return[Hold[None], Module ] ];
                        BoxForm`IconsStore[iconHash] = Hold[iconTempSymbol];
                        iconTempSymbol = icon;
                        Hold[iconTempSymbol]
                      ]
                      
                    ]},
  
    If[False (* not supported for NOW *),
      Module[{temporalStorage},
        With[{
          result = RowBox[{headString, "[", "(*VB[*) ", ToString[temporalStorage, InputForm], " (*,*)(*", ToString[Compress[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden] ], InputForm ], "*)(*]VB*)", "]"}]
        },
          AppendTo[BoxForm`temporal, Hold[temporalStorage] ];

          temporalStorage = Sequence @@ interpretation;
          result
        ]
      ]
    ,
      With[{interpretationString = ToString[interpretation, InputForm]},
        If[event === Null,
          RowBox[{headString, "[", "(*VB[*) ", StringDrop[StringDrop[interpretationString, -1], StringLength[headString] + 1], " (*,*)(*", ToString[Compress[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden] ], InputForm ], "*)(*]VB*)", "]"}]
        ,
          RowBox[{headString, "[", "(*VB[*) ", StringDrop[StringDrop[interpretationString, -1], StringLength[headString] + 1], " (*,*)(*", ToString[Compress[ProvidedOptions[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden], "Event" -> event] ], InputForm ], "*)(*]VB*)", "]"}]
        ]
      ]
    ]
    
  ]
]


SetAttributes[BoxForm`ArrangeSummaryBox, HoldAll]




(**)
System`WLXEmbed /: MakeBoxes[w_System`WLXEmbed, StandardForm] := With[{o = CreateFrontEndObject[w]}, MakeBoxes[o, StandardForm] ]
