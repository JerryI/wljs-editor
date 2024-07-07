BeginPackage["Notebook`EditorUtils`", {"JerryI`Misc`Events`", "Notebook`Editor`FrontendObject`"}]

FrontEditorSelected::usage = "A frontend function FrontEditorSelected[\"Get\"] gets the selected content. FrontEditorSelected[\"Set\", value] inserts or replaces content"
EditorView::usage = "A view component for an editor instance EditorView[_String, opts___], where \"Event\" id can be provided for tracking changes. It supports dynamic updates as well."

InputEditor::usage = "InputEditor[string_] _EventObject"


Begin["`Private`"]


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
