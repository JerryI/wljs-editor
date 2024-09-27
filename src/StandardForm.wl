System`RowBoxFlatten;
RowBoxFlatten[x_List, y___] := StringJoin @@ (ToString[#] & /@ x)


Begin["Notebook`Editor`StandardForm`"]

System`DatasetWrapper;
System`AudioWrapper;
System`VideoWrapper;
System`ByteArrayWrapper;
System`QuantityWrapper;
System`TreeWrapper;

(* Overrride FormatValues*)
(* FIXME *)
ExpressionReplacements = {
    s_Sound :> CreateFrontEndObject[s ],
    a_Audio :> AudioWrapper[a],
    b_ByteArray :> ByteArrayWrapper[b],
    d_Dataset :> DatasetWrapper[d],
    u_Quantity :> QuantityWrapper[u],
    v_Video :> VideoWrapper[v],
    t_Tree :> TreeWrapper[t],
    TreeForm[expr_] :> (ExpressionTree[Unevaluated[expr] ] /. t_Tree :> TreeWrapper[t])
} // Quiet

Unprotect[ToString]
ToString[expr_, StandardForm] := ExportString[
    StringReplace[
        (expr /. ExpressionReplacements // ToBoxes) /. {RowBox->RowBoxFlatten} // ToString
    , {"\[NoBreak]"->""}]
, "String"]


Unprotect[ClearAll]
ClearAll["Global`*"] := Print["Cleaning global scope is not allowed!"]
Protect[ClearAll]

End[]
