

BeginPackage["Notebook`Editor`Kernel`FrontSubmitService`MetaMarkers`", {
    "Notebook`Editor`Kernel`FrontSubmitService`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]

MetaMarker::usage = "MetaMarker[_String] an object to mark entities on frontend to be used for selection and evaluation"

MarkerContainer;

Begin["`Private`"]

notString[s_] := !StringQ[s]
MetaMarker[s_?notString] := MetaMarker[s // ToString]



FrontSubmit[expr_, m_MetaMarker, OptionsPattern[] ] := With[{cli = OptionValue["Window"]["Socket"]},
    If[OptionValue["Tracking"],     
        With[{uid = CreateUUID[]}, 
            If[FailureQ[WLJSTransportSend[MarkerContainer[FrontEndInstanceGroup[expr, uid], m], cli] ], $Failed,
                FrontEndInstanceGroup[uid, OptionValue["Window"] ]
            ] 
        ]
    ,
        If[FailureQ[WLJSTransportSend[MarkerContainer[expr, m], cli] ], $Failed,
            Null
        ]          
    ]
    
]

FrontFetchAsync[expr_, m_MetaMarker, OptionsPattern[] ] := With[{cli = OptionValue["Window"]["Socket"], format = OptionValue["Format"], event = CreateUUID[], promise = Promise[]},
    EventHandler[event, Function[payload,
        EventRemove[event];

        With[{result = Switch[format,
            "Raw",
                URLDecode[payload],
            "ExpressionJSON",
                ImportString[URLDecode[payload], "ExpressionJSON"],
            _,
                ImportString[URLDecode[payload], "JSON"]
        ]},
            If[FailureQ[result],
                EventFire[promise, Reject, result]
            ,
                EventFire[promise, Resolve, result]
            ]
        ]
    ] ];

    WLJSTransportSend[Global`FSAsk[MarkerContainer[expr,m], event], cli];

    promise
]

End[]

EndPackage[]