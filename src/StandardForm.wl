Begin["Notebook`Editor`StandardForm`"]

(* Being unable to change Boxes of Graphics, Graphics3D and Image, we have to use this *)
ExpressionReplacements = {
    Graphics[opts__] :> CreateFrontEndObject[Graphics[opts]], 
    Graphics3D[opts__] :> CreateFrontEndObject[Graphics3D[opts]], 
    Image[opts__] :> CreateFrontEndObject[Image[opts]]
}

RowBoxFlatten[x_List, y___] := StringJoin @@ (ToString[#] & /@ x)

Unprotect[ToString]
ToString[expr_, StandardForm] := StringReplace[(expr /. ExpressionReplacements // ToBoxes) /. {RowBox->RowBoxFlatten} // ToString, {"\[NoBreak]"->""}]



End[]