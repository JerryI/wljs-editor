Unprotect[FrameBox]
FrameBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[FrameBox[opts]]], InputForm]]

Unprotect[StyleBox]
StyleBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[StyleBox[opts]]], InputForm]]

CustomBox[x_, opts__] := FrontEndBox[x, ToString[Compress[Hold[opts]], InputForm]]

(*InterpretationBox[boxes,expr]	interpret boxes as representing the expression expr - replace expressions with a box instead of styling*)

Normal[FrontEndBox[expr_, view_]] ^:= expr