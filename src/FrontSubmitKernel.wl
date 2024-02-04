

BeginPackage["Notebook`Editor`Kernel`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]

FrontSubmit::usage = "FrontSubmit[expr] to evaluation on frontend"
CurrentWindow::usage = "Gets current window representation"

FrontFetch::usage = "FrontFetch[expr] fetches an expression from frontend"
FrontFetchAsync::usage = "FrontFetchAsync[expr] fetches an expression from frontend and returns Promise"

Begin["`Private`"]

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

    WLJSTransportSend[Global`FSAsk[expr, event], cli]

    promise
]

FrontFetch[expr_, opts___] := FrontFetchAsync[expr, opts] // WaitAll

Options[FrontFetchAsync] = {"Format"->"ExpressionJSON", "Window" :> Global`$EvaluationContext["KernelWebSocket"]};

CurrentWindow[] := Global`$EvaluationContext["KernelWebSocket"]

FrontSubmit[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"]},
    WLJSTransportSend[expr, cli]
]

Options[FrontSubmit] = {"Window" :> Global`$EvaluationContext["KernelWebSocket"]}

End[]
EndPackage[]