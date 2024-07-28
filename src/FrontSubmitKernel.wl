

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


WindowObj;
WindowObj::usage = "Internal represenation of a current window"

Begin["`Private`"]

CurrentWindow[] := WindowObj[<|"Socket" -> Global`$EvaluationContext["KernelWebSocket"]|>]

WindowObj[data_][key_String] := data[key]

FrontFetchAsync[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"]["Socket"], format = OptionValue["Format"], event = CreateUUID[], promise = Promise[]},
    EventHandler[event, Function[payload,
        EventRemove[event];

        With[{result = Switch[format,
            "Raw",
                FromCharacterCode@ToCharacterCode[URLDecode[payload], "UTF-8"],
            "ExpressionJSON",
                ImportString[FromCharacterCode@ToCharacterCode[URLDecode[payload], "UTF-8"], "ExpressionJSON"],
            _,
                ImportString[FromCharacterCode@ToCharacterCode[URLDecode[payload], "UTF-8"], "JSON"]
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

FrontSubmit[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"]["Socket"]},
    If[OptionValue["Tracking"],     
        With[{uid = CreateUUID[]}, 
            If[FailureQ[WLJSTransportSend[FrontEndInstanceGroup[expr, uid], cli] ], $Failed,
                FrontEndInstanceGroup[uid, OptionValue["Window"] ]
            ] 
        ]
    ,
        If[FailureQ[WLJSTransportSend[expr, cli] ], $Failed,
            Null
        ]          
    ]
]

FrontEndInstanceGroup /: Delete[FrontEndInstanceGroup[uid_String, win_WindowObj], OptionsPattern[{"Window" :> CurrentWindow[]}] ] := With[{},
    If[FailureQ[WLJSTransportSend[FrontEndInstanceGroupDestroy[uid], win["Socket"] ] ], $Failed,
        Null
    ]
]

Options[FrontSubmit] = {"Window" :> CurrentWindow[], "Tracking" -> False}

End[]
EndPackage[]