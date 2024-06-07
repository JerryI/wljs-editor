
(* Workarounds for Mathematica's Boxes *)
(* The road of pain, blood and tears *)

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

System`ByteArrayWrapper;
ByteArrayWrapper /: MakeBoxes[ByteArrayWrapper[b_ByteArray], form_] := ByteArrayBox[b, form]

Kernel`Internal`garbage = {};

ByteArrayBox[b_ByteArray, form_] := With[{
  size = UnitConvert[Quantity[ByteCount[b], "Bytes"], "Conventional"] // TextString
},
  If[ByteCount[b] > 1024,
    LeakyModule[{
      store
    },
      With[{view = 
        Module[{above, below},
              above = { 
                {BoxForm`SummaryItem[{"Size: ", Style[size, Bold]}]},
                {BoxForm`SummaryItem[{"Location", Style["Kernel", Italic, Red]}]}
              };

              BoxForm`ArrangeSummaryBox[
                 ByteArray, (* head *)
                 ByteArray[store],      (* interpretation *)
                 None,    (* icon, use None if not needed *)
                 (* above and below must be in a format suitable for Grid or Column *)
                 above,    (* always shown content *)
                 Null (* expandable content. Currently not supported!*)
              ] // Quiet
          ]        
        },
       
        AppendTo[Kernel`Internal`garbage , Hold[store] ]; (* Garbage collector bug for ByteArrays *)
        store = BaseEncode[b];
        

        view
      ]
    ]
  ,
    Module[{above, below},
        above = { 
          {BoxForm`SummaryItem[{"Size: ", Style[size, Bold]}]}
        };

        BoxForm`ArrangeSummaryBox[
           ByteArray, (* head *)
           b,      (* interpretation *)
           None,    (* icon, use None if not needed *)
           (* above and below must be in a format suitable for Grid or Column *)
           above,    (* always shown content *)
           Null (* expandable content. Currently not supported!*)
        ]
    ]
  ]
] // Quiet


TagBox["ByteArray", "SummaryHead"] = ""

(* FIX for WL14 *)
TagBox[any_, f_Function] := any

Unprotect[FrameBox]
FrameBox[x_, opts__]  := RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[FrameBox[opts]]], InputForm], "*)(*]BB*)"}]

(* FIXME!!! *)
Kernel`Internal`trimStringCharacters[s_String] := With[{
  c = StringTake[s, 1]
},
  If[c === "\"",
    StringDrop[StringDrop[s, -1], 1]
  ,
    StringReplace[s, "\[Times]"-> (ToString[Style[" x ", RGBColor[0.5,0.5,0.5] ], StandardForm]) ]
  ]
]

Unprotect[StyleBox]

(* FIXME!!! *)
(* FIXME!!! *)
(* FIXME!!! *)
StyleBox[x_, opts__]  := With[{list = Association[List[opts] ]},
  If[KeyExistsQ[list, ShowStringCharacters], 
    If[!list[ShowStringCharacters],
      RowBox[{"(*BB[*)(", ReplaceAll[x, s_String :> Kernel`Internal`trimStringCharacters[s] ], ")(*,*)(*", ToString[Compress[Hold[StyleBox[opts]]], InputForm], "*)(*]BB*)"}]  
    ,
      RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[StyleBox[opts]]], InputForm], "*)(*]BB*)"}]
    ]
  ,
    RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[StyleBox[opts]]], InputForm], "*)(*]BB*)"}]
  ]
]

System`ProvidedOptions;

(*if a string, then remove quotes*)
Unprotect[Style]
Style /: MakeBoxes[Style[s_String, opts__], StandardForm] := StringBox[s, opts]
StringBox[x_String, opts__]  := RowBox[{"(*BB[*)(", ToString[x, InputForm], ")(*,*)(*", ToString[Compress[ProvidedOptions[Hold[StringBox[opts] ], "String"->True ] ], InputForm], "*)(*]BB*)"}, "String"->True]


Unprotect[PanelBox]
PanelBox[x_, opts__]  := RowBox[{"(*BB[*)(Panel[", x, "])(*,*)(*", ToString[Compress[Hold[ProvidedOptions[PanelBox[opts], "Head"->"Panel"]]], InputForm], "*)(*]BB*)"}]

iHighlight[expr_] := Style[expr, Background->Yellow]

Unprotect[TemplateBox]

TemplateBox[list_List, "RowDefault"] := GridBox[{list}]

(* I HATE YOU WOLFRAM !!! *)
(*TemplateBox[a:{n_, short_String, long_String, units_String}, "Quantity", o___] := Module[{test}, With[{
  expr = Quantity[n // ToExpression, units] // QuantityMagnitude
}, 
  test = {a, o};
  With[{realUnits = test[[1,1]] // ToExpression},
    RowBox[{"(*VB[*)(", StringTemplate["Quantity[``, ``]"][realUnits, units], ")(*,*)(*", ToString[Compress[ QuantityBox[realUnits, StringDrop[StringDrop[short, -1], 1] ] ], InputForm], "*)(*]VB*)"}]
  ]
] ]*)

System`QuantityWrapper;
QuantityWrapper /: MakeBoxes[QuantityWrapper[q_Quantity], StandardForm] := With[{
  n = QuantityMagnitude[q],
  units = QuantityUnit[q]
},
  ViewBox[q, QuantityBox[n, units] ]
] 

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




Unprotect[Iconize]
ClearAll[Iconize]

Iconize[expr_, opts: OptionsPattern[] ] := With[{UID = OptionValue["UID"]},
  If[ByteCount[expr] > 30000,
    With[{name = "iconized-"<>StringTake[UID, 4]<>".wl"},
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

Options[Iconize] = {"Label"->None, "UID":>CreateUUID[]}


IconizedFile /: MakeBoxes[IconizedFile[c_, b_, opts___], StandardForm] := RowBox[{"(*VB[*)(Get[FileNameJoin[", ToString[c, InputForm], "]])(*,*)(*", ToString[Compress[Hold[IconizeFileBox[b, opts] ] ], InputForm], "*)(*]VB*)"}]
Iconized /: MakeBoxes[Iconized[c_, b_, opts___], StandardForm] := RowBox[{"(*VB[*)(Uncompress[", ToString[c, InputForm], "])(*,*)(*", ToString[Compress[Hold[IconizeBox[b, opts] ] ], InputForm], "*)(*]VB*)"}]


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

Options[BoxForm`ArrangeSummaryBox] = Append[Options[BoxForm`ArrangeSummaryBox], "Event"->Null]



SetAttributes[BoxForm`ArrangeSummaryBox, HoldAll]

Unprotect[Graph]
Graph /: MakeBoxes[g_Graph, StandardForm] := With[{c = Insert[GraphPlot[g, ImageSize->120, ImagePadding->None], JerryI`Notebook`Graphics2D`Controls->False, {2,-1}] /. Notebook`Editor`StandardForm`ExpressionReplacements}, ViewBox[g, c] ]


Unprotect[PaneBox]
PaneBox[expr_, a__] := BoxBox[expr, Offload[PaneBox[a] ] ]


