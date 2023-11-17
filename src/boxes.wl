Unprotect[FractionBox]
FractionBox[a_, b_] := RowBox[{"(*FB[*)((", a, ")(*,*)/(*,*)(", b, "))(*]FB*)"}]

(*depricated!!! only for compatibillity with older notebooks*)
CM6FractionExpression[x_, y_]:= x/y
(*depricated!!! only for compatibillity with older notebooks*)
ExpressionMaker[CM6Fraction -> CM6FractionExpression, StandardForm]

(*CM6Fraction /: CMCrawler[CM6Fraction[a_, b_], StandardForm] := With[{x = CMCrawler[a, StandardForm], y = CMCrawler[b, StandardForm]}, x/y]*)

Unprotect[SqrtBox]
SqrtBox[a_] := RowBox[{"(*SqB[*)Sqrt[", a, "](*]SqB*)"}]


(*depricated!!! only for compatibillity with older notebooks*)
ExpressionMaker[CM6Sqrt -> Sqrt, StandardForm]

(*CM6Sqrt /: CMCrawler[CM6Sqrt[a_], StandardForm] := Sqrt[CMCrawler[a, StandardForm]]*)

Unprotect[SuperscriptBox]
SuperscriptBox[a_, b_] := RowBox[{"(*SpB[*)Power[", a, "(*|*),(*|*)",  b, "](*]SpB*)"}]


(*depricated!!! only for compatibillity with older notebooks*)
ExpressionMaker[CM6Superscript -> Power, StandardForm]

(*CM6Superscript /: CMCrawler[CM6Superscript[a_, b_], StandardForm] := Power[CMCrawler[a, StandardForm], CMCrawler[b, StandardForm]]*)

Unprotect[SubscriptBox]
SubscriptBox[a_, b_] := RowBox[{"(*SbB[*)Subscript[", a, "(*|*),(*|*)",  b, "](*]SbB*)"}]

(*depricated!!! only for compatibillity with older notebooks*)
ExpressionMaker[CM6Subscript -> Subscript, StandardForm]

(*CM6Subscript /: CMCrawler[CM6Subscript[a_, b_], StandardForm] := Subscript[CMCrawler[a, StandardForm], CMCrawler[b, StandardForm]]*)

Unprotect[GridBox]
GridBox[list_List, a___] := RowBox@(Join@@(Join[{{"(*GB[*){"}}, Riffle[#, {{"(*||*),(*||*)"}}] &@ (Join[{"{"}, Riffle[#, "(*|*),(*|*)"], {"}"}] &/@ list), {{"}(*]GB*)"}}]))

(*depricated!!! only for compatibillity with older notebooks*)
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

TagBox["ByteArray", "SummaryHead"] = ""

Unprotect[FrameBox]
FrameBox[x_, opts__]  := RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[FrameBox[opts]]], InputForm], "*)(*]BB*)"}]

Unprotect[StyleBox]
StyleBox[x_, opts__]  := RowBox[{"(*BB[*)(", x, ")(*,*)(*", ToString[Compress[Hold[StyleBox[opts]]], InputForm], "*)(*]BB*)"}]


(*InterpretationBox[boxes,expr]	interpret boxes as representing the expression expr - replace expressions with a box instead of styling*)

iHighlight[expr_] := Style[expr, Background->Yellow]

ExpressionMaker[FrontEndBoxTemporal -> FrontEndBoxTemporalExpression, StandardForm]
FrontEndBoxTemporalExpression[expr_, a_] := expr
(*FrontEndBoxTemporal /: CMCrawler[FrontEndBoxTemporal[expr_, a_], StandardForm] := expr*)


Unprotect[TemplateBox]

TemplateBox[list_List, "RowDefault"] := GridBox[{list}]

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
ViewBox[expr_, display_] := RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[display]], InputForm], "*)(*]VB*)"}]
BoxBox[expr_, display_] := RowBox[{"(*BB[*)(", expr, ")(*,*)(*", ToString[Compress[Hold[display]], InputForm], "*)(*]BB*)"}]


Unprotect[PaneSelectorBox]

PaneSelectorBox[list_, opts___] := list[[1]][[2]]

Unprotect[InterpretationBox]

(* ToString[, InputForm] is IMPORTANT!!! *)

InterpretationBox[placeholder_, expr_, opts___] := With[{data = expr, v = EditorView[ToString[placeholder /. {RowBox->RowBoxFlatten}], ReadOnly->True]},
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[v]], InputForm], "*)(*]VB*)"}]
]


(*
InterpretationBox[RowBox[view_List], expr_, opts___] := With[{data = expr, v = InterpretationBoxView[view]},
  Print[view];
  Print["Bytes!!!!!"];
  RowBox[{"(*VB[*)(", ToString[expr, InputForm], ")(*,*)(*", ToString[Compress[Hold[v]], InputForm], "*)(*]VB*)"}]
]


InterpretationBoxView[{TagBox["ByteArray", "SummaryHead"], "[", content_, "]"}] := (Print["Bytes!!!!!"]; content)
InterpretationBoxView[list_] := (Print["Bytes!!!!!"]; EditorView[ToString[RowBox[list] /. {RowBox->RowBoFlxatten}], ReadOnly->True])


FrontEndView /: ToString[FrontEndView[x_, y_], arg___] := ToString[FrontEndView, arg]<>"["<>ExportString[x, "Text"]<>","<>ToString[y, arg]<>"]";
*)

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