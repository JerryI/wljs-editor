BeginPackage["Notebook`EditorUtils`", {"JerryI`Misc`Events`"}]

FrontEditorSelected::usage = "A frontend function FrontEditorSelected[\"Get\"] gets the selected content. FrontEditorSelected[\"Set\", value] inserts or replaces content"
EditorView::usage = "A view component for an editor instance EditorView[_String, opts___], where \"Event\" id can be provided for tracking changes. It supports dynamic updates as well."

InputEditor::usage = "InputEditor[string_] _EventObject"

ViewBox::usage = "ViewBox[expr_, decorator_] low-level box used by InterpretationBox. It keeps `expr` in its original form, while visially covers it with DOM element to which `decorator` expression will be attached and executed"
BoxBox::usage = "BoxBox[expr_Box | _String, decorator_] low-level box used by Style, Framed... It places a subeditor with `expr` inside and decorates the container using `decorator` expression will be attached and executed."

Begin["`Private`"]

InputEditor[str_String] := With[{id = CreateUUID[]},
    EventObject[<|"Id"->id, "Initial"->str, "View"->EditorView[str, "Event"->id]|>]
]

InputEditor[str_] := With[{id = CreateUUID[]},
    EventObject[<|"Id"->id, "Initial"->First[str], "View"->EditorView[str, "Event"->id]|>]
]

End[]
EndPackage[]
