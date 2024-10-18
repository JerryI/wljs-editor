

BeginPackage["Notebook`Editor`Kernel`FrontEndRuntime`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`"
}]

FrontEndRuntime::usage = "FrontEndRuntime[] gives a list of properties possible to extend during the runtime"

Begin["`Internal`"]

FrontEndRuntime[any_List] := With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "RequestRuntimeExtensions", <|"Promise" -> (promise), "Kernel"->Internal`Kernel`Hash|>];
        promise // WaitAll
    ]

FrontEndRuntime /: Set[FrontEndRuntime[key_], data_List] := With[{promise = Promise[]},
        EventFire[Internal`Kernel`CommunicationChannel, "UpdateRuntimeExtensions", <|"Promise" -> (promise), "Kernel"->Internal`Kernel`Hash, "Data"->data, "Key"->key|>];
        promise // WaitAll
    ]

End[]
EndPackage[]
