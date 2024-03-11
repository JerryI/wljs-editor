BeginPackage["Notebook`EditorUtils`", {"JerryI`Misc`Events`", "Notebook`Editor`FrontendObject`"}]

FrontEditorSelected::usage = "A frontend function FrontEditorSelected[\"Get\"] gets the selected content. FrontEditorSelected[\"Set\", value] inserts or replaces content"
EditorView::usage = "A view component for an editor instance EditorView[_String, opts___], where \"Event\" id can be provided for tracking changes. It supports dynamic updates as well."

InputEditor::usage = "InputEditor[string_] _EventObject"

ViewBox::usage = "ViewBox[expr_, decorator_] low-level box used by InterpretationBox. It keeps `expr` in its original form, while visially covers it with DOM element to which `decorator` expression will be attached and executed"
ViewBox`InnerExpression::usage = "ViewBox`InnerExpression[expr_] sets content of a view box being evaluated inside the container (see MetaMarker)"
ViewBox`OuterExpression::usage = "ViewBox`OuterExpression[expr_] sets content of a th whole view box being evaluated inside the container (see MetaMarker)"

BoxBox::usage = "BoxBox[expr_Box | _String, decorator_, opts___] low-level box used by Style, Framed... It places a subeditor with `expr` inside and decorates the container using `decorator` expression will be attached and executed. \"Head\" is an option for inserting the head"

Begin["`Private`"]

notString[s_] := !StringQ[s]
ViewBox`InnerExpression[s_?notString] := ViewBox`InnerExpression[ ToString[s, StandardForm] ]

notString[s_] := !StringQ[s]
ViewBox`OuterExpression[s_?notString] := ViewBox`OuterExpression[ ToString[s, StandardForm] ]

InputEditor[str_String] := With[{id = CreateUUID[]},
    EventObject[<|"Id"->id, "Initial"->str, "View"->EditorView[str, "Event"->id]|>]
]

InputEditor[] := InputEditor[""]

InputEditor[str_] := With[{id = CreateUUID[]},
    EventObject[<|"Id"->id, "Initial"->First[str], "View"->EditorView[str, "Event"->id]|>]
]

EditorView /: MakeBoxes[e_EditorView, StandardForm] := With[{o = CreateFrontEndObject[e]}, MakeBoxes[o, StandardForm] ]


End[]
EndPackage[]
