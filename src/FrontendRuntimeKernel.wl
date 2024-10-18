

BeginPackage["Notebook`Editor`Kernel`FrontEndRuntime`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

FrontEndRuntime::usage = "FrontEndRuntime[] gives a list of properties possible to extend during the runtime"

Begin["`Internal`"]

FrontEndRuntime[any_List] := With[{r = FrontEndRuntime[]},
    If[FailureQ[r],
        $Failed
    ,
        r[any]
    ]
]

FrontEndRuntime[] := With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "RequestRuntimeExtensions", <|"Promise" -> (promise), "Kernel"->Internal`Kernel`Hash|>];
        With[{r = (promise // WaitAll)},
            r
        ]
    ]

FrontEndRuntime /: Set[FrontEndRuntime[key_], data_List] := With[{promise = Promise[]},
    With[{
        list = Select[data /. {File[path_String] :> Import[path, "Text"]}, StringQ]
    },
        EventFire[Internal`Kernel`CommunicationChannel, "UpdateRuntimeExtensions", <|"Promise" -> (promise), "Kernel"->Internal`Kernel`Hash, "Data"->list, "Key"->key|>];
        promise // WaitAll
    ]
]

End[]
EndPackage[]
