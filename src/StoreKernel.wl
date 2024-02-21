BeginPackage["Notebook`Storage`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "Notebook`CellOperations`"
}]

NotebookStore::usage = "Use is as an association NotebookStore[\"Key\", opts] to store object in the notebook, opts: \"Notebook\"->_RemoteNotebook object. See EvaluatingNotebook[]"

Begin["`Private`"]

NotebookStore /: Keys[ NotebookStore[ OptionsPattern[] ] ] := With[{notebook = OptionValue[NotebookStore, "Notebook"] // First},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "NotebookStoreGetKeys", <|"Ref"->notebook, "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] 
]

NotebookStore[key_String, OptionsPattern[] ] := With[{notebook = OptionValue[NotebookStore, "Notebook"] // First},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "NotebookStoreGet", <|"Ref"->notebook, "Key"->key, "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll 
    ] // Uncompress
]

NotebookStore /: Set[NotebookStore[key_String, OptionsPattern[] ], data_] := With[{notebook = OptionValue[NotebookStore, "Notebook"] // First},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "NotebookStoreSet", <|"Ref"->notebook, "Key"->key, "Data"->Compress[data], "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] 
]

NotebookStore /: Unset[NotebookStore[key_String, OptionsPattern[] ] ] := With[{notebook = OptionValue[NotebookStore, "Notebook"] // First},
    With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "NotebookStoreUnset", <|"Ref"->notebook, "Key"->key, "Promise" -> promise, "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ] 
]

Options[NotebookStore] = {"Notebook" :> RemoteNotebook[ Global`$EvaluationContext["Notebook"] ]}

End[]
EndPackage[]