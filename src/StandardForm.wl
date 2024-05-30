RowBoxFlatten[x_List, y___] := StringJoin @@ (ToString[#] & /@ x)

Begin["Notebook`Editor`StandardForm`"]

System`DatasetWrapper;
System`AudioWrapper;
System`ByteArrayWrapper;

(* Being unable to change Boxes of Graphics, Graphics3D and Image, we have to use this *)
(* FIXME *)
ExpressionReplacements = {
    g2d_Graphics :> CreateFrontEndObject[g2d ], 
    g3d_Graphics3D :> CreateFrontEndObject[g3d ], 
    i_Image :> CreateFrontEndObject[i ],
    s_Sound :> CreateFrontEndObject[s ],
    s_Audio :> AudioWrapper[s],
    b_ByteArray :> ByteArrayWrapper[b],
    d_Dataset :> DatasetWrapper[d]
} // Quiet

Unprotect[ToString]
ToString[expr_, StandardForm] := ExportString[
    StringReplace[
        (expr /. ExpressionReplacements // ToBoxes) /. {RowBox->RowBoxFlatten} // ToString
    , {"\[NoBreak]"->""}]
, "String"]


End[]
