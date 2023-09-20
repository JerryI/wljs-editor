Unprotect[FrameBox]
FrameBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[FrameBox[opts]]], InputForm]]

Unprotect[StyleBox]
StyleBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[StyleBox[opts]]], InputForm]]

CustomBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[opts]], InputForm]]

(*InterpretationBox[boxes,expr]	interpret boxes as representing the expression expr - replace expressions with a box instead of styling*)

Normal[FrontEndBox[expr_, view_]] ^:= expr

Unprotect[TemplateBox]

TemplateBox[assoc_Association, "RGBColorSwatchTemplate"] := With[{color = assoc["color"]},
    FrontEndView[assoc["color"], ToString[Compress[Hold[RGBColorSwatchTemplate[color]]], InputForm]]
]

TemplateBox[expr_List, "DateObject", __] := With[{date = expr[[1]][[1]][[1]]},
   FrontEndView[expr[[2]], ToString[Compress[Hold[DateObjectTemplate[date]]], InputForm]]
]