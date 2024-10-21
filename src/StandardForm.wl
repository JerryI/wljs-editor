System`RowBoxFlatten;
RowBoxFlatten[x_List, y___] := StringJoin @@ (ToString[#] & /@ x)


Begin["Notebook`Editor`StandardForm`"]


System`ByteArrayWrapper;
System`TreeWrapper;

(* Overrride FormatValues*)
(* FIXME *)
ExpressionReplacements = {
    b_ByteArray :> ByteArrayWrapper[b],
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
