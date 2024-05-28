RowBoxFlatten[x_List, y___] := StringJoin @@ (ToString[#] & /@ x)

Begin["Notebook`Editor`StandardForm`"]

System`DatasetWrapper;

(* Being unable to change Boxes of Graphics, Graphics3D and Image, we have to use this *)
(* FIXME *)
ExpressionReplacements = {
    Graphics[opts__] :> CreateFrontEndObject[Graphics[opts] ], 
    Graphics3D[opts__] :> CreateFrontEndObject[Graphics3D[opts] ], 
    Image[opts__] :> CreateFrontEndObject[Image[opts] ],
    Sound[opts__] :> CreateFrontEndObject[Sound[opts] ],
    d_Dataset :> DatasetWrapper[d]
} // Quiet

Unprotect[ToString]
ToString[expr_, StandardForm] := ExportString[
    StringReplace[
        (expr /. ExpressionReplacements // ToBoxes) /. {RowBox->RowBoxFlatten} // ToString
    , {"\[NoBreak]"->""}]
, "String"]


End[]
