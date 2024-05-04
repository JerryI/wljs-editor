

BeginPackage["Notebook`Editor`Kernel`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]

(*Offload::usage = "Offload[exp] to keep it from evaluation on Kernel"*)

FrontSubmit::usage = "FrontSubmit[expr] _FrontEndInstanceGroup (taken from global stack) to evaluation on frontend"
CurrentWindow::usage = "Gets current window representation"

FrontFetch::usage = "FrontFetch[expr] fetches an expression from frontend"
FrontFetchAsync::usage = "FrontFetchAsync[expr] fetches an expression from frontend and returns Promise"

FrontEndInstanceGroup::usage = "FrontEndInstanceGroup[uid_String] an identifier object of an executed expression on the frontend"

FrontEndInstanceGroupDestroy;

Begin["`Private`"]

CurrentWindow[] := Global`$EvaluationContext["KernelWebSocket"]

FrontFetchAsync[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"], format = OptionValue["Format"], event = CreateUUID[], promise = Promise[]},
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

    WLJSTransportSend[Global`FSAsk[expr, event], cli];

    promise
]

FrontFetch[expr_, opts___] := FrontFetchAsync[expr, opts] // WaitAll

Options[FrontFetch] = {"Format"->"JSON", "Window" :> CurrentWindow[]};
Options[FrontFetchAsync] = {"Format"->"JSON", "Window" :> CurrentWindow[]};

FrontSubmit[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"]},
    If[OptionValue["Tracking"],     
        With[{uid = CreateUUID[]}, 
            If[FailureQ[WLJSTransportSend[FrontEndInstanceGroup[expr, uid], cli] ], $Failed,
                FrontEndInstanceGroup[uid]
            ] 
        ]
    ,
        If[FailureQ[WLJSTransportSend[expr, cli] ], $Failed,
            Null
        ]          
    ]
]

FrontEndInstanceGroup /: Delete[FrontEndInstanceGroup[uid_String], OptionsPattern[{"Window" :> CurrentWindow[]}] ] := With[{win = OptionValue["Window"]},
    If[FailureQ[WLJSTransportSend[FrontEndInstanceGroupDestroy[uid], win] ], $Failed,
        Null
    ]
]

Options[FrontSubmit] = {"Window" :> CurrentWindow[], "Tracking" -> False}

End[]
EndPackage[]