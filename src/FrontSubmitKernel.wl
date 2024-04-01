

BeginPackage["Notebook`Editor`Kernel`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]

(*Offload::usage = "Offload[exp] to keep it from evaluation on Kernel"*)

FrontSubmit::usage = "FrontSubmit[expr] _FrontEndInstance (taken from global stack) to evaluation on frontend"
CurrentWindow::usage = "Gets current window representation"

FrontFetch::usage = "FrontFetch[expr] fetches an expression from frontend"
FrontFetchAsync::usage = "FrontFetchAsync[expr] fetches an expression from frontend and returns Promise"

FrontEndInstance::usage = "FrontEndInstance[uid_String] an identifier object of an executed expression on the frontend"

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
            If[WLJSTransportSend[FrontEndInstance[expr, uid], cli] < 0, $Failed,
                FrontEndInstance[uid]
            ] 
        ]
    ,
        If[WLJSTransportSend[expr, cli] < 0, $Failed,
            Null
        ]          
    ]
]

FrontEndInstance /: Delete[FrontEndInstance[uid_String], OptionsPattern[{"Window" :> CurrentWindow[]}] ] := With[{win = OptionValue["WIndow"]},
    If[WLJSTransportSend[FrontEndInstanceDelete[uid], win] < 0, $Failed,
        Null
    ]
]

Options[FrontSubmit] = {"Window" :> CurrentWindow[], "Tracking" -> False}

End[]
EndPackage[]