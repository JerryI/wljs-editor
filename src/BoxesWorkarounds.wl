
(* Workarounds for Mathematica's Boxes *)
(* The road of pain, blood and tears *)

Unprotect[FractionBox]
FractionBox[a_, b_] := RowBox[{"(*FB[*)((", a, ")(*,*)/(*,*)(", b, "))(*]FB*)"}]

Unprotect[SqrtBox]
SqrtBox[a_] := RowBox[{"(*SqB[*)Sqrt[", a, "](*]SqB*)"}]

Unprotect[RotationBox]
RotationBox[expr_, OptionsPattern[] ] := With[{o = OptionValue["BoxRotation"]}, BoxBox[expr, RotationBox[o] // Hold] ]
Options[RotationBox] = {"BoxRotation" -> 90. Degree}

Unprotect[SuperscriptBox]
SuperscriptBox[a_, b_] := RowBox[{"(*SpB[*)Power[", a, "(*|*),(*|*)",  b, "](*]SpB*)"}]
SuperscriptBox[a_, b_, _] := RowBox[{"(*SpB[*)Power[", a, "(*|*),(*|*)",  b, "](*]SpB*)"}]

SuperscriptBox[a_, "\[Prime]", _] := RowBox[{a, "'"}]
SuperscriptBox[a_, ",", _] := RowBox[{a, "'"}]

System`TransposeBox;
Unprotect[Transpose]
Transpose /: MakeBoxes[t: Transpose[expr_], StandardForm]:= With[{boxes = MakeBoxes[expr, StandardForm]},
  BoxBox[expr, TransposeBox["T"], Head->Transpose]
]

Unprotect[ConjugateTranspose]
ConjugateTranspose /: MakeBoxes[t: ConjugateTranspose[expr_], StandardForm]:= With[{boxes = MakeBoxes[expr, StandardForm]},
  BoxBox[expr, TransposeBox["&dagger;"], Head->ConjugateTranspose]
]

Unprotect[Sum]
System`SumBox;


Sum /: MakeBoxes[Sum[expr_, {x_Symbol, min_, max_}], s: StandardForm] := With[{func = MakeBoxes[expr, s]},
    With[{dp = SumBox[1, True], symbol = MakeBoxes[x, s], bmin = MakeBoxes[min, s], bmax = MakeBoxes[max, s]},
      RowBox[{"(*TB[*)Sum[(*|*)", func, "(*|*), {(*|*)", symbol, "(*|*),(*|*)", bmin, "(*|*),(*|*)", bmax, "(*|*)}](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Sum /: MakeBoxes[Sum[expr_, vars__List], s: StandardForm] := With[{list = List[vars]},
    With[{dp = SumBox[1, True], func = MakeBoxes[expr, s], symbols = Riffle[
        With[{sym = #[[1]], min = #[[2]], max = #[[3]]},
          If[Length[#] === 3,
            {"{(*|*)", MakeBoxes[sym, s], "(*|*),(*|*)", MakeBoxes[min, s], "(*|*),(*|*)", MakeBoxes[max, s], "(*|*)}"}
          ,
            {"{(*|*)", MakeBoxes[sym, s], "(*|*),(*|*)", MakeBoxes[min, s], "(*|*),(*|*)", MakeBoxes[max, s], "(*|*)", ToString[#[[4]], InputForm],"}"}
          ]
          
        ] &/@ list
      , ","] // Flatten // RowBox
    },
      RowBox[{"(*TB[*)Sum[(*|*)", func, "(*|*), ", symbols, "](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Sum /: MakeBoxes[Sum[expr_, {x_Symbol, min_, max_, step_}], s: StandardForm] := With[{func = MakeBoxes[expr, s]},
    With[{dp = SumBox[1, True], symbol = MakeBoxes[x, s], bmin = MakeBoxes[min, s], bmax = MakeBoxes[max, s], bstep = MakeBoxes[step, s]},
      RowBox[{"(*TB[*)Sum[(*|*)", func, "(*|*), {(*|*)", symbol, "(*|*),(*|*)", bmin, "(*|*),(*|*)", bmax, "(*|*)", bstep, "}](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Unprotect[Derivative]
Derivative /: MakeBoxes[Derivative[single_][f_], s: StandardForm] := With[{},
  RowBox[{MakeBoxes[f, s], StringJoin @@ Table["'", {i, single}]}]
]

System`DerivativeBox;

Derivative /: MakeBoxes[Derivative[multi__][f_], s: StandardForm] := With[{list = List[multi]},
  With[{func = MakeBoxes[f, s], head = "Derivative["<>StringRiffle[ToString/@list, ","]<>"]"},
    With[{dp = ProvidedOptions[DerivativeBox[list], "Head"->head]},
      RowBox[{"(*BB[*)(", head, "[", func, "])(*,*)(*", ToString[Compress[dp ], InputForm], "*)(*]BB*)"}]
    ]
  ]
]

Unprotect[Integrate]
System`IntegrateBox;

Integrate /: MakeBoxes[Integrate[f_, x_Symbol], s: StandardForm ] := With[{},
    With[{dp = IntegrateBox[1, False], func = MakeBoxes[f, s], symbol = MakeBoxes[x, s]},
      RowBox[{"(*TB[*)Integrate[(*|*)", func, "(*|*), (*|*)", symbol, "(*|*)](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Integrate /: MakeBoxes[Integrate[f_, x__Symbol], s: StandardForm ] := With[{list = List[x]},
    With[{dp = IntegrateBox[list // Length, False], func = MakeBoxes[f, s], symbols = RowBox[Riffle[MakeBoxes[#, s]&/@list, "(*|*),(*|*)"] ]},
      RowBox[{"(*TB[*)Integrate[(*|*)", func, "(*|*), (*|*)", symbols, "(*|*)](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Integrate /: MakeBoxes[Integrate[f_, {x_Symbol, min_, max_}], s: StandardForm ] := With[{},
    With[{dp = IntegrateBox[1, True], func = MakeBoxes[f, s], symbol = MakeBoxes[x, s], xmin = MakeBoxes[min, s], xmax = MakeBoxes[max, s]},
      RowBox[{"(*TB[*)Integrate[(*|*)", func, "(*|*), {(*|*)", symbol, "(*|*),(*|*)",xmin,"(*|*),(*|*)",xmax,"(*|*)}](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

Integrate /: MakeBoxes[Integrate[f_, bond__List], s: StandardForm ] := With[{list = List[bond]},
    With[{dp = IntegrateBox[list // Length, True], func = MakeBoxes[f, s], symbols = RowBox[Riffle[{
        With[{var = #[[1]], min = #[[2]], max = #[[3]]},
          {"{(*|*)", MakeBoxes[var, s], "(*|*),(*|*)", MakeBoxes[min, s], "(*|*),(*|*)", MakeBoxes[max, s], "(*|*)}"}
        ]
      }&/@list, ","] // Flatten ]},
      RowBox[{"(*TB[*)Integrate[(*|*)", func, "(*|*), ", symbols, "](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
]

SuperscriptBox[a_, "\[Transpose]"] := RowBox[{"Transpose[", a, "]"}]

RowBox[{SuperscriptBox["f", TagBox[RowBox[{"(", RowBox[{"1", ",", "1"}], ")"}], Derivative], MultilineFunction -> None], "[", RowBox[{"x", ",", "y"}], "]"}]

Unprotect[SubsuperscriptBox]
SubsuperscriptBox[x_?(Not[# === "\[Sum]"]&), y_, z_] := SuperscriptBox[SubscriptBox[x,y], z]
SubsuperscriptBox[x_?(Not[# === "\[Sum]"]&), y_, z_, __] := SuperscriptBox[SubscriptBox[x,y], z]

Unprotect[RowBox]
RowBox[{first___, SubsuperscriptBox["\[Sum]", iterator_, till_], f_, rest___}] := RowBox[{first, "Sum[", f, ", {", iterator, ",", till, "}]",  rest}]
RowBox[{first___, SubsuperscriptBox["\[Sum]", RowBox[{iterator_, "=", initial_}], till_], f_, rest___}] := RowBox[{first, "Sum[", f, ", {", iterator, ",", initial, ",", till, "}]",  rest}]


Unprotect[SubscriptBox]
SubscriptBox[a_, b_] := RowBox[{"(*SbB[*)Subscript[", a, "(*|*),(*|*)",  b, "](*]SbB*)"}]
SubscriptBox[a_, b_, _] := RowBox[{"(*SbB[*)Subscript[", a, "(*|*),(*|*)",  b, "](*]SbB*)"}]

(* we do support only one option*)
Unprotect[GridBox]
GridBox[list_List, opts___] := With[{sorted = Association[ List[opts] ]},
If[!KeyExistsQ[sorted, GridBoxDividers],
 RowBox@(Join @@ (Join[{{"(*GB[*){"}}, 
     Riffle[
      (Join[{"{"}, Riffle[#, "(*|*),(*|*)"], {"}"}] & /@ list), 
      If[Length[list] > 1, {{"(*||*),(*||*)"}}, {}] ], {{"}(*]GB*)"}}]))
,
With[{val = sorted[GridBoxDividers]},
 RowBox@(Join @@ (Join[{{"(*GB[*){"}}, 
     Riffle[
      (Join[{"{"}, Riffle[#, "(*|*),(*|*)"], {"}"}] & /@ list), 
      If[Length[list] > 1, {{"(*||*),(*||*)"}}, {}] ], {{StringJoin["}(*||*)(*", Compress[GridBox[GridBoxDividers -> val ] // Hold ], "*)(*]GB*)"]}}]))
]
] ]


System`PiecewiseBox;
GridBox[{{"\[Piecewise]", whatever_}}, a___] := With[{original = whatever /. {RowBox -> RowBoxFlatten} // ToString // ToExpression},
  With[{
    dp = PiecewiseBox[ Length[original] ]
  },
    With[{boxes = Riffle[
      With[{
        val = #[[1]],
        cond = #[[2]]
      },
        {"{(*|*)", MakeBoxes[val, StandardForm], "(*|*),(*|*)", MakeBoxes[cond, StandardForm], "(*|*)}"}
      ]& /@ original
    , ","] // Flatten // RowBox},
      RowBox[{"(*TB[*)Piecewise[{", boxes, "}](*|*)(*", Compress[dp], "*)(*]TB*)"}]
    ]
  ]
]



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

System`TreeWrapper;
TreeWrapper /: MakeBoxes[TreeWrapper[t_Tree], StandardForm] := With[{c = Insert[GraphPlot[t, VertexLabels->Automatic, ImageSize->180, ImagePadding->None] /. {
  Text[{HoldComplete[text_], _}, rest__] :>  {Black, Text[ToString[text], rest]},
  Text[{text_, _}, rest__] :>  {Black, Text[ToString[text], rest]},
  Text[text_, rest__] :>  {Black, Text[ToString[text], rest]}
}, JerryI`Notebook`Graphics2D`Controls->False, {2,-1}] /. Notebook`Editor`StandardForm`ExpressionReplacements}, ViewBox[t, c] ]


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
StyleBox[x_, opts__]  := With[{list = Association[Cases[List[opts], _Rule] ]},
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
System`StringBox;

(*if a string, then remove quotes*)
Unprotect[Style]
Style /: MakeBoxes[Style[s_String, opts__], StandardForm] := StringBox[s, opts]
StringBox[x_String, opts__]  := RowBox[{"(*BB[*)(", ToString[x, InputForm], ")(*,*)(*", ToString[Compress[ProvidedOptions[Hold[StringBox[opts] ], "String"->True ] ], InputForm], "*)(*]BB*)"}, "String"->True]

Unprotect[Panel]
Panel /: EventHandler[p_Panel, list_List] := With[{
  uid = CreateUUID[],
  assoc = Association[list]
},
  EventHandler[uid, assoc["Click"] ];
  Insert[p, "Event"->uid, -1]
]

Unprotect[PanelBox]
PanelBox[x_, opts___]  := RowBox[{"(*BB[*)(Panel[", x, "])(*,*)(*", ToString[Compress[Hold[ProvidedOptions[PanelBox[opts], "Head"->"Panel"]]], InputForm], "*)(*]BB*)"}]

iHighlight[expr_] := Style[expr, Background->Yellow]

Unprotect[TemplateBox]

TemplateBox[list_List, "RowDefault", ___] := GridBox[{list}]
TemplateBox[list_List, "Row", ___] := GridBox[{list}]

TemplateBox[{pts_Integer}, "Spacer"] := ViewBox[Spacer[pts], SpacerBox[pts] ]
TemplateBox[{pts_Integer}, "Spacer1"] := ViewBox[Spacer[pts], SpacerBox[pts] ]
TemplateBox[{pts__Integer}, "Spacer2"] := ViewBox[Spacer[pts], SpacerBox[List[pts] ] ]

TemplateBox[list:{expr_, label_}, "Labeled", opts__Rule ] := With[{func = Association[ List[opts] ][DisplayFunction]},
  func @@ list
]

Unprotect[ItemBox]

ItemBox[expr_, o: OptionsPattern[] ] := RowBox[{expr, "(*VB[*)(**)(*,*)(*", ToString[Compress[ItemBox[o] // Hold ], InputForm], "*)(*]VB*)"}] ;/ Head[expr] =!= Slot

(* I HATE YOU WOLFRAM !!! *)
(*TemplateBox[a:{n_, short_String, long_String, units_String}, "Quantity", o___] := Module[{test}, With[{
  expr = Quantity[n // ToExpression, units] // QuantityMagnitude
}, 
  test = {a, o};
  With[{realUnits = test[[1,1]] // ToExpression},
    RowBox[{"(*VB[*)(", StringTemplate["Quantity[``, ``]"][realUnits, units], ")(*,*)(*", ToString[Compress[ QuantityBox[realUnits, StringDrop[StringDrop[short, -1], 1] ] ], InputForm], "*)(*]VB*)"}]
  ]
] ]*)

Unprotect[QuantityUnits`QuantityBox]
ClearAll[QuantityUnits`QuantityBox]
System`QuantityBox;

QuantityUnits`QuantityBox[QuantityUnits`Private`x_, QuantityUnits`Private`frmt_] := With[{
  n = QuantityMagnitude[QuantityUnits`Private`x],
  units = QuantityUnit[QuantityUnits`Private`x]
},
  ViewBox[q, QuantityBox[n, units] ]
]

System`RootBox;
TemplateBox[{"Root", m_, raw_, approx_}, opts___] := RowBox[{"(*VB[*)(", approx /. {RowBox->RowBoxFlatten} // ToString, ")(*,*)(*", ToString[Compress[RootBox[approx] ] , InputForm], "*)(*]VB*)"}]

TemplateBox[{number_}, "C"] := RowBox[{ SubscriptBox[C, number]}]

TemplateBox[expr_, "Bra"] := With[{dp = ProvidedOptions[BraDecorator, "Head"->"Bra"]}, RowBox[{"(*BB[*)(Bra[", RowBox[Riffle[expr, ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]
TemplateBox[expr_, "Ket"] := With[{dp = ProvidedOptions[KetDecorator, "Head"->"Ket"]}, RowBox[{"(*BB[*)(Ket[", RowBox[Riffle[expr, ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

TemplateBox[{file_String}, "FileArgument"] := file

System`ConditionalBox;

TemplateBox[{expr_, cond_}, "ConditionalExpression"] := With[{dp = ConditionalBox},
  RowBox[{"(*TB[*)ConditionalExpression[(*|*)", expr, "(*|*), (*|*)", cond, "(*|*)](*|*)(*", Compress[dp], "*)(*]TB*)"}]
]

TemplateBox[expr_, "IconizedObject"] := "\"Box is not implemented\""

Unprotect[Ket]
Unprotect[Bra]

System`KetDecorator;
System`BraDecorator;

Ket /: MakeBoxes[Ket[list__], StandardForm] := With[{dp = ProvidedOptions[KetDecorator, "Head"->"Ket"]}, RowBox[{"(*BB[*)(Ket[", RowBox[Riffle[List[list], ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

Bra /: MakeBoxes[Bra[list__], StandardForm] := With[{dp = ProvidedOptions[BraDecorator, "Head"->"Bra"]}, RowBox[{"(*BB[*)(Bra[", RowBox[Riffle[List[list], ","]], "])(*,*)(*", ToString[Compress[dp], InputForm], "*)(*]BB*)"}]]

Unprotect[DynamicModuleBox]
(* fallback *)
DynamicModuleBox[vars_, body_] := body

TemplateBox[assoc_Association, "RGBColorSwatchTemplate"] := With[{color = assoc["color"]//N},
   RowBox[{"(*VB[*)(", ToString[assoc["color"], InputForm], ")(*,*)(*", ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[assoc_Association, "GrayLevelColorSwatchTemplate"] := With[{color = assoc["color"]//N // RGBColor},
   RowBox[{"(*VB[*)(", ToString[assoc["color"], InputForm], ")(*,*)(*", ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[assoc_Association, "HueColorSwatchTemplate"] := With[{color = assoc["color"]//N // RGBColor},
   RowBox[{"(*VB[*)(", ToString[assoc["color"], InputForm], ")(*,*)(*", ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[expr_List, "DateObject", __] := With[{date = expr[[1]][[1]][[1]]},
   RowBox[{"(*VB[*)(", expr[[2]], ")(*,*)(*", ToString[Compress[Hold[DateObjectTemplate[date]]], InputForm], "*)(*]VB*)"}]
]

TemplateBox[expr_List, "SummaryPanel"] := RowBox[expr]




Unprotect[Iconize]
ClearAll[Iconize]

System`IconizedFile;
System`Iconized;

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

System`InterpretationOptimized;

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

Unprotect[Show]
Show[any_, DisplayFunction->Identity] := any 
Protect[Show]


Legended /: MakeBoxes[Legended[expr_, SwatchLegend[l_List, names_List] ], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[SwatchLegend[l_, names_List, opts__], _, Identity]}], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[SwatchLegend[{head_List, l_List}, {{}, names_List}, opts__], _, Identity]}], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[SwatchLegend[l_List, names_List, opts__], _, Identity] ], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[PointLegend[l_List, names_List, opts__], _, Identity] ], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[LineLegend[l_, names_List, opts__], _, Identity]}], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[LineLegend[l_, names_List, opts__], _, Identity] ], f: StandardForm] := With[{o = {expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[BarLegend[a__], n__]} ], f: StandardForm] := MakeBoxes[Legended[expr, Placed[BarLegend[a], n] ], f]




System`WLXForm;

Unprotect[System`DateObjectDump`makeDateObjectBox]
Unprotect[DateObject]

DateObject /: System`DateObjectDump`makeDateObjectBox[System`DateObjectDump`dObj:DateObject[System`DateObjectDump`date_,___], WLXForm] := With[{res = TextString[System`DateObjectDump`dObj]}, res/;System`DateObjectDump`fname=!=$Failed]

System`DateObjectDump`makeDateObjectBox[System`DateObjectDump`dObj:DateObject[System`DateObjectDump`date_,___], WLXForm] := With[{res = TextString[System`DateObjectDump`dObj]}, res/;System`DateObjectDump`fname=!=$Failed]

(* have to convert to FE, since there is no wljs-editor avalable to interpretate RowBoxes*)

Legended /: MakeBoxes[Legended[expr_, SwatchLegend[l_List, names_List] ], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[SwatchLegend[l_, names_List, opts__], _, Identity]}], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[SwatchLegend[{head_List, l_List}, {{}, names_List}, opts__], _, Identity]}], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[SwatchLegend[l_List, names_List, opts__], _, Identity] ], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[PointLegend[l_List, names_List, opts__], _, Identity] ], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, {Placed[LineLegend[l_, names_List, opts__], _, Identity]}], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]

Legended /: MakeBoxes[Legended[expr_, Placed[LineLegend[l_, names_List, opts__], _, Identity] ], f: WLXForm] := With[{o = ToString[{expr, ({l, Internal`RawText /@ (names /. HoldForm -> Identity)} /.{Directive[_, color_RGBColor, ___] :> color }) //Transpose// Grid} // Row, StandardForm] // EditorView // CreateFrontEndObject}, MakeBoxes[o, f] ]


Legended /: MakeBoxes[Legended[expr_, Placed[BarLegend[{cf_, range_List}, opts___Rule, ___] , _, Identity] ], f: (StandardForm | WLXForm)] := With[{
  ticks = Table[{Round[i, (range[[2]] - range[[1]])/20.0], Null}, {i, range[[1]], range[[2]], (range[[2]] - range[[1]])/10.0}]
},
  With[{
    legend =   With[{options = Association[List[opts] ]}, 
    
    Module[{colorConvert, step = (ticks[[2, 1]] - ticks[[1, 1]]) * 0.5, 
      imageSize = 
        If[KeyExistsQ[options, ImageSize], options[ImageSize], 370 / 1.6180339  ]},
      
      (* Adjust the image size depending on whether it is a list or not *)
      imageSize = 
        1.2 If[!ListQ[imageSize], 
          (* If it's not a list, scale by the golden ratio *)
          imageSize {0.3, 1.0} ,
          (* If it's a list, adjust by the second element *)
          imageSize[[2]] {0.3, 1.0} // N
        ];
      
      (* Color conversion function based on range *)
      colorConvert[value_] := 
        cf @ ((value - range[[1]]) / (range[[2]] - range[[1]]));
      
      (* Create the graphic with rectangles for each tick *)
      Graphics[
        Map[
          Function[tick, 
            With[{val = tick[[1]], deco = tick[[2 ;;]]}, 
              {colorConvert[val], 
               Rectangle[{-1, val - step}, {1, val + step}]}
            ]
          ], 
          ticks
        ], 
        Axes -> True, Frame -> True, 
        FrameTicks -> {{{}, ticks[[All, 1]]}, {False, False}}, 
        TickLabels -> {False, False, False, True}, 
        PlotRange -> {{-1, 1}, range}, 
        "Controls" -> False, 
        ImageSize -> imageSize, 
        ImagePadding -> 25
      ]
    ]
  ]
  },
  
  With[{
    box = Row[{expr, legend // CreateFrontEndObject}]
  },
    If[f == StandardForm,
      MakeBoxes[box, f]
    ,
      With[{s = ToString[box, StandardForm]},
        With[{e = EditorView[s] // CreateFrontEndObject},
          MakeBoxes[e, WLXForm]
        ]
      ]
    ]
  ]
  
  ]
]


Unprotect[BoxForm`ArrangeSummaryBox]
ClearAll[BoxForm`ArrangeSummaryBox]

Unprotect[BoxForm`SummaryItem]

BoxForm`SummaryItem[{label_String, view_}] := BoxForm`SummaryItemView[label, EditorView[ToString[view, StandardForm], "ReadyOnly"->True]]

BoxForm`IconsStore = <||>;

BoxForm`temporal = {};

Options[BoxForm`ArrangeSummaryBox] = {"Event" -> Null}

BoxForm`ArrangeSummaryBox[head_, interpretation_, icon_, above_, hidden_, ___, OptionsPattern[] ] := With[{
  headString = If[!StringQ[head], ToString[head, InputForm], head],
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
  If[ByteCount[interpretation] < 2 8 2500,               
  With[{interpretationString = ToString[interpretation, InputForm]},
    If[StringLength[interpretationString] > 2500,
      Module[{temporalStorage},
        With[{
          tempSymbol = ToString[temporalStorage, InputForm],
          viewBox = StringRiffle[{headString, "[(*VB[*) ", "(*,*)(*", ToString[Compress[ProvidedOptions[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden], "DataOnKernel"->True ] ], InputForm ], "*)(*]VB*)]"}, ""]
        },
          AppendTo[BoxForm`temporal, Hold[temporalStorage] ];

          temporalStorage = interpretation;

          With[{fakeEditor = EditorView[viewBox, "ReadOnly"->True]},
            RowBox[{"(*VB[*)", tempSymbol, "(*,*)(*", ToString[Compress[fakeEditor], InputForm ], "*)(*]VB*)"}]
          ]
        ]
      ]
    ,
      
        If[event === Null,
          If[Head[interpretation] =!= head,
            RowBox[{headString, "[", "(*VB[*) ", interpretationString, " (*,*)(*", ToString[Compress[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden] ], InputForm ], "*)(*]VB*)", "]"}]          
          ,
            RowBox[{headString, "[", "(*VB[*) ", StringDrop[StringDrop[interpretationString, -1], StringLength[headString] + 1], " (*,*)(*", ToString[Compress[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden] ], InputForm ], "*)(*]VB*)", "]"}]
          ]
        ,
          If[Head[interpretation] =!= head,
            RowBox[{headString, "[", "(*VB[*) ", interpretationString, " (*,*)(*", ToString[Compress[ProvidedOptions[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden], "Event" -> event] ], InputForm ], "*)(*]VB*)", "]"}]
          ,
            RowBox[{headString, "[", "(*VB[*) ", StringDrop[StringDrop[interpretationString, -1], StringLength[headString] + 1], " (*,*)(*", ToString[Compress[ProvidedOptions[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden], "Event" -> event] ], InputForm ], "*)(*]VB*)", "]"}]
          ]
        ]
      
    ]
  ],
      Module[{temporalStorage},
        With[{
          tempSymbol = ToString[temporalStorage, InputForm],
          viewBox = StringRiffle[{headString, "[(*VB[*) ", "(*,*)(*", ToString[Compress[ProvidedOptions[BoxForm`ArrangedSummaryBox[iconSymbol // FrontEndVirtual, above, hidden], "DataOnKernel"->True ] ], InputForm ], "*)(*]VB*)]"}, ""]
        },
          AppendTo[BoxForm`temporal, Hold[temporalStorage] ];

          temporalStorage = interpretation;

          With[{fakeEditor = EditorView[viewBox, "ReadOnly"->True]},
            RowBox[{"(*VB[*)", tempSymbol, "(*,*)(*", ToString[Compress[fakeEditor], InputForm ], "*)(*]VB*)"}]
          ]
        ]
      ]
  ]
  ]
] // Quiet

Options[BoxForm`ArrangeSummaryBox] = Append[Options[BoxForm`ArrangeSummaryBox], "Event"->Null]



SetAttributes[BoxForm`ArrangeSummaryBox, HoldAll]

Unprotect[Graph]
Graph /: MakeBoxes[g_Graph, StandardForm] := With[{c = Insert[GraphPlot[g, ImageSize->120, ImagePadding->None] /. {Text[text_, rest__] :>  {Black, Text[ToString[text], rest]}}, JerryI`Notebook`Graphics2D`Controls->False, {2,-1}] /. Notebook`Editor`StandardForm`ExpressionReplacements}, ViewBox[g, c] ]


Unprotect[PaneBox]
PaneBox[expr_, a___] := BoxBox[expr, Offload[PaneBox[a] ] ]

Unprotect[Pane]
Pane /: EventHandler[p_Pane, list_List] := With[{
  uid = CreateUUID[],
  assoc = Association[list]
},
  EventHandler[uid, assoc["Click"] ];
  Insert[p, "Event"->uid, -1]
]


Unprotect[BoundaryMeshRegion]
BoundaryMeshRegion /: MakeBoxes[b_BoundaryMeshRegion, StandardForm] := With[{r = If[RegionDimension[b] == 3, RegionPlot3D[b, ImageSize->200], Insert[RegionPlot[b, ImageSize->200, Axes->False, Frame->False, ImagePadding->10], JerryI`Notebook`Graphics2D`Controls->False, {2,-1}]] // CreateFrontEndObject},
  If[ByteCount[b] > 5250,
    LeakyModule[{temporal},
      With[{v = ViewBox[temporal, r]},
        AppendTo[Kernel`Internal`garbage, Hold[temporal]];
        temporal = b;
        v
      ]
    ]
    
  ,
    ViewBox[b, r]
  ]
  
]

Unprotect[MeshRegion]
MeshRegion /: MakeBoxes[b_MeshRegion, StandardForm] := With[{r = If[RegionDimension[b] == 3, RegionPlot3D[b, ImageSize->200], Insert[RegionPlot[b, ImageSize->200, Axes->False, Frame->False, ImagePadding->10], JerryI`Notebook`Graphics2D`Controls->False, {2,-1}]] // CreateFrontEndObject},
  If[ByteCount[b] > 5250,
    LeakyModule[{temporal},
      With[{v = ViewBox[temporal, r]},
        AppendTo[Kernel`Internal`garbage, Hold[temporal]];
        temporal = b;
        v
      ]
    ]
    
  ,
    ViewBox[b, r]
  ]
]


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

System`WLXEmbed /: MakeBoxes[w_System`WLXEmbed, StandardForm] := With[{o = CreateFrontEndObject[w]}, MakeBoxes[o, StandardForm] ]



Unprotect[Row]

Row /: MakeBoxes[Row[expr__, OptionsPattern[] ], WLXForm] := With[{list = List[expr]},
  With[{Res = Map[MakeBoxes[#, WLXForm]&, list]},
    StringJoin["<div class=\"flex flex-row\">", StringRiffle[Res, "\n"], "</div>"]
  ]
]

Row /: MakeBoxes[Row[expr_List, OptionsPattern[] ], WLXForm] := With[{list = expr},
  With[{Res = Map[MakeBoxes[#, WLXForm]&, list]},
    StringJoin["<div class=\"flex flex-row\">", StringRiffle[Res, "\n"], "</div>"]
  ]
]

Unprotect[Column]

Column /: MakeBoxes[Column[expr__, OptionsPattern[] ], WLXForm] := With[{list = List[expr]},
  With[{Res = Map[MakeBoxes[#, WLXForm]&, list]},
    StringJoin["<div class=\"flex flex-col\">", StringRiffle[Res, "\n"], "</div>"]
  ]
]

Column /: MakeBoxes[Column[expr_List, OptionsPattern[] ], WLXForm] := With[{list = expr},
  With[{Res = Map[MakeBoxes[#, WLXForm]&, list]},
    StringJoin["<div class=\"flex flex-row\">", StringRiffle[Res, "\n"], "</div>"]
  ]
]

Unprotect[Squiggled]

Unprotect[Style]

Style[Style[expr_, a__], b__] := Style[expr, b, a]

Squiggled[expr_, color_:Lighter[Red] ] := Style[expr, Underlined -> color]

Unprotect[GeoGraphics]

GeoGraphics /: MakeBoxes[System`GeoGraphicsDump`g:GeoGraphics[Graphics[System`GeoGraphicsDump`toshow_, System`GeoGraphicsDump`gropts___], System`GeoGraphicsDump`rest___], System`GeoGraphicsDump`fmt_] := With[{},
  Message["Not implemented in WLJS, we are sorry"];
  $Failed
]

General::wljsunsupported = "Symbol `` is not supported in WLJS. We are sorry";

(* unsupported! *)
With[{ unsupported = {GraphicsRow, WordCloud, GraphicsColumn, GeoGraphics, InputField, GraphicsGrid, GalleryView, FormObject, FormFunction, FormPage, Toggler, Opener, Setter, RadioButton, Control, CheckboxBar, RadioButtonBar, Setter, Checkbox, Button, Toggler, SetterBar, RadioButton, Checkbox, PopupMenu, FileNameSetter, ColorSetter, Trigger, HorizontalGauge, Setter, BulletGauge, AngularGauge, ThermometerGauge, Slider, VerticalSlider, Slider2D, IntervalSlider, Manipulator, HorizontalGauge, Locator, Slider2D, ColorSlider, LocatorPane, SlideView, MenuView, FlipView, PopupView, OpenerView, PaneSelector}},
  Do[With[{item = i},
    Unprotect[item];
    ClearAll[item];
  ], {i, unsupported}]
];


System`EntityBox;
Unprotect[Entity];

Entity /: MakeBoxes[EntityFramework`Formatting`Private`x_Entity,
     EntityFramework`Formatting`Private`fmt_
    ] :=
    (Entity;With[{EntityFramework`Formatting`Private`boxes = ViewBox[EntityFramework`Formatting`Private`x, EntityBox[EntityTypeName[EntityFramework`Formatting`Private`x], EntityFramework`Formatting`Private`x//EntityValue //TextString ] ]},
        
        EntityFramework`Formatting`Private`boxes/;EntityFramework`Formatting`Private`boxes=!=$Failed
])

Unprotect[EntityFramework`MakeEntityFrameworkBoxes]
ClearAll[EntityFramework`MakeEntityFrameworkBoxes]
EntityFramework`MakeEntityFrameworkBoxes[EntityFramework`Formatting`Private`x_Entity,
     EntityFramework`Formatting`Private`fmt_] := With[{EntityFramework`Formatting`Private`boxes = ViewBox[EntityFramework`Formatting`Private`x, EntityBox[EntityTypeName[EntityFramework`Formatting`Private`x], EntityFramework`Formatting`Private`x//EntityValue //TextString ]]},
        
        EntityFramework`Formatting`Private`boxes
]