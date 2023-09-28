Unprotect[FrameBox]
FrameBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[FrameBox[opts]]], InputForm]]

Unprotect[StyleBox]
StyleBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[StyleBox[opts]]], InputForm]]

CustomBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[opts]], InputForm]]

(*InterpretationBox[boxes,expr]	interpret boxes as representing the expression expr - replace expressions with a box instead of styling*)

iHighlight[expr_] := FrontEndBoxTemporal[expr, ToString[Compress[Hold[StyleBox[Background->RGBColor[1,1,0]]]], InputForm]]

FrontEndBoxTemporalWrapper[expr_, __] := expr

Normal[FrontEndBox[expr_, view_]] ^:= expr

Unprotect[TemplateBox]

Unprotect[DynamicModuleBox]
(* fallback *)
DynamicModuleBox[vars_, body_] := body

TemplateBox[assoc_Association, "RGBColorSwatchTemplate"] := With[{color = assoc["color"]//N},
    FrontEndView[assoc["color"], ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm]]
]

TemplateBox[expr_List, "DateObject", __] := With[{date = expr[[1]][[1]][[1]]},
   FrontEndView[expr[[2]], ToString[Compress[Hold[DateObjectTemplate[date]]], InputForm]]
]

Unprotect[InterpretationBox]

InterpretationBox[RowBox[view_List], expr_, opts___] := With[{data = expr, v = InterpretationBoxView[view]},
   FrontEndView[expr, ToString[Compress[Hold[v]], InputForm]]
]

InterpretationBoxView[{TagBox["ByteArray", "SummaryHead"], "[", content_, "]"}] := content

TemplateBox[v_List, "SummaryPanel"] := v

(* fallback 


TemplateBox[{PaneSelectorBox[{False -> GridBox[{{GridBox[{{TagBox["\\\"3 bytes\\\"", "SummaryItem"]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Automatic}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, GridBoxSpacings -> {"Columns" -> {{2}}, "Rows" -> {{Automatic}}}, BaseStyle -> {ShowStringCharacters -> False, NumberMarks -> False, PrintPrecision -> 3, ShowSyntaxStyles -> False}]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Top}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, BaselinePosition -> {1, 1}], True -> GridBox[{{GridBox[{{TagBox["\\\"3 bytes\\\"", "SummaryItem"]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Automatic}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, GridBoxSpacings -> {"Columns" -> {{2}}, "Rows" -> {{Automatic}}}, BaseStyle -> {ShowStringCharacters -> False, NumberMarks -> False, PrintPrecision -> 3, ShowSyntaxStyles -> False}]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Top}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, BaselinePosition -> {1, 1}]}, Dynamic[Typeset`open$$], ImageSize -> Automatic]}, "SummaryPanel"]

*)