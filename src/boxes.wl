Unprotect[FractionBox]
FractionBox[a_, b_] := CM6Fraction[a,b]
CM6FractionExpression[x_, y_]:= x/y

ExpressionMaker[CM6Fraction -> CM6FractionExpression, StandardForm]

(*CM6Fraction /: CMCrawler[CM6Fraction[a_, b_], StandardForm] := With[{x = CMCrawler[a, StandardForm], y = CMCrawler[b, StandardForm]}, x/y]*)

Unprotect[SqrtBox]
SqrtBox[a_] := CM6Sqrt[a]
ExpressionMaker[CM6Sqrt -> Sqrt, StandardForm]

(*CM6Sqrt /: CMCrawler[CM6Sqrt[a_], StandardForm] := Sqrt[CMCrawler[a, StandardForm]]*)

Unprotect[SuperscriptBox]
SuperscriptBox[a_, b_] := CM6Superscript[a,b]

ExpressionMaker[CM6Superscript -> Power, StandardForm]

(*CM6Superscript /: CMCrawler[CM6Superscript[a_, b_], StandardForm] := Power[CMCrawler[a, StandardForm], CMCrawler[b, StandardForm]]*)

Unprotect[SubscriptBox]
SubscriptBox[a_, b_] := CM6Subscript[a,b]

ExpressionMaker[CM6Subscript -> Subscript, StandardForm]

(*CM6Subscript /: CMCrawler[CM6Subscript[a_, b_], StandardForm] := Subscript[CMCrawler[a, StandardForm], CMCrawler[b, StandardForm]]*)

Unprotect[GridBox]
GridBox[list_List, a___] := CM6Grid[list]
ExpressionMaker[CM6Grid -> Identity, StandardForm]
(*CM6Grid  /: CMCrawler[CM6Grid[a_], StandardForm] := CMCrawler[a, StandardForm]*)


FrontEndExecutableExpression[uid_] :=  (Print["Importing string"]; ImportString[
  Function[res, If[!StringQ[res], 
                  Print["nope!"];
                  JerryI`WolframJSFrontend`Evaluator`objects[uid] = AskMaster[Global`NotebookGetObjectForMe[uid]];
                  JerryI`WolframJSFrontend`Evaluator`objects[uid]["json"]
                  ,
                  Print["got it!"];
                  res
    ]
  ] @ (JerryI`WolframJSFrontend`Evaluator`objects[uid]["json"])
, "ExpressionJSON"] // ReleaseHold );

FrontEndInlineExecutableExpression[str_String] := Uncompress[str]

ExpressionMaker[FrontEndExecutable -> FrontEndExecutableExpression, StandardForm]
ExpressionMaker[FrontEndInlineExecutable -> FrontEndInlineExecutableExpression, StandardForm]

(*FrontEndExecutable /: CMCrawler[FrontEndExecutable[uid_], StandardForm] :=  (Print["Importing string"]; ImportString[
  Function[res, If[!StringQ[res], 
                  JerryI`WolframJSFrontend`Evaluator`objects[uid] = AskMaster[Global`NotebookGetObjectForMe[uid]];
                  JerryI`WolframJSFrontend`Evaluator`objects[uid]["json"]
                  ,
                  res
    ]
  ] @ (JerryI`WolframJSFrontend`Evaluator`objects[uid]["json"])
, "ExpressionJSON"] // ReleaseHold );*)

Unprotect[TagBox]
TagBox[x_, opts___] := x

Unprotect[FrameBox]
FrameBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[FrameBox[opts]]], InputForm]]

Unprotect[StyleBox]
StyleBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[StyleBox[opts]]], InputForm]]

CustomBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[opts]], InputForm]]

(*InterpretationBox[boxes,expr]	interpret boxes as representing the expression expr - replace expressions with a box instead of styling*)

iHighlight[expr_] := FrontEndBoxTemporal[expr, ToString[Compress[Hold[StyleBox[Background->RGBColor[1,1,0]]]], InputForm]]

ExpressionMaker[FrontEndBoxTemporal -> FrontEndBoxTemporalExpression, StandardForm]
FrontEndBoxTemporalExpression[expr_, a_] := expr
(*FrontEndBoxTemporal /: CMCrawler[FrontEndBoxTemporal[expr_, a_], StandardForm] := expr*)

Normal[FrontEndBox[expr_, view_]] ^:= expr

Unprotect[TemplateBox]

TemplateBox[list_List, "RowDefault"] := CM6Grid[{list}]

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

InterpretationBox[placeholder_, expr_, opts___] := With[{data = expr, v = EditorView[ToString[placeholder /. {RowBox->RowBoxFlatten}], ReadOnly->True]},
  FrontEndView[expr, ToString[Compress[Hold[v]], InputForm]]
]

InterpretationBox[RowBox[view_List], expr_, opts___] := With[{data = expr, v = InterpretationBoxView[view]},
  Print[view];
  FrontEndView[expr, ToString[Compress[Hold[v]], InputForm]]
]

InterpretationBoxView[{TagBox["ByteArray", "SummaryHead"], "[", content_, "]"}] := content
InterpretationBoxView[list_] := EditorView[ToString[RowBox[list] /. {RowBox->RowBoxFlatten}], ReadOnly->True]

FrontEndView /: ToString[FrontEndView[x_, y_], arg___] := ToString[FrontEndView, arg]<>"["<>ExportString[x, "Text"]<>","<>ToString[y, arg]<>"]";

FrontEndViewExpression[expr_, a_] := expr;
ExpressionMaker[FrontEndView -> FrontEndViewExpression, StandardForm]
(*FrontEndView /: CMCrawler[FrontEndView[expr_, a_], StandardForm] := expr*)


TemplateBox[v_List, "SummaryPanel"] := v

EventObjectHasView[assoc_Association] := KeyExistsQ[assoc, "view"]
EventObject /: MakeBoxes[EventObject[a_?EventObjectHasView], StandardForm] := With[{o = CreateFrontEndObject[a["view"]]}, MakeBoxes[o, StandardForm]]


FrontEndTruncated /: MakeBoxes[FrontEndTruncated[a__], StandardForm] := With[{o = CreateFrontEndObject[FrontEndTruncated[a]]}, MakeBoxes[o, StandardForm]]

(* fallback 


TemplateBox[{PaneSelectorBox[{False -> GridBox[{{GridBox[{{TagBox["\\\"3 bytes\\\"", "SummaryItem"]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Automatic}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, GridBoxSpacings -> {"Columns" -> {{2}}, "Rows" -> {{Automatic}}}, BaseStyle -> {ShowStringCharacters -> False, NumberMarks -> False, PrintPrecision -> 3, ShowSyntaxStyles -> False}]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Top}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, BaselinePosition -> {1, 1}], True -> GridBox[{{GridBox[{{TagBox["\\\"3 bytes\\\"", "SummaryItem"]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Automatic}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, GridBoxSpacings -> {"Columns" -> {{2}}, "Rows" -> {{Automatic}}}, BaseStyle -> {ShowStringCharacters -> False, NumberMarks -> False, PrintPrecision -> 3, ShowSyntaxStyles -> False}]}}, GridBoxAlignment -> {"Columns" -> {{Left}}, "Rows" -> {{Top}}}, AutoDelete -> False, GridBoxItemSize -> {"Columns" -> {{Automatic}}, "Rows" -> {{Automatic}}}, BaselinePosition -> {1, 1}]}, Dynamic[Typeset`open$$], ImageSize -> Automatic]}, "SummaryPanel"]

*)



JerryI`WolframJSFrontend`Evaluator`KeepExpression[Graphics]
JerryI`WolframJSFrontend`Evaluator`KeepExpression[Graphics3D]
JerryI`WolframJSFrontend`Evaluator`KeepExpression[GraphicsBox, "Epilog"->True]
JerryI`WolframJSFrontend`Evaluator`KeepExpression[Image]