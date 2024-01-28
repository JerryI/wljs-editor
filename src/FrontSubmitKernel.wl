

BeginPackage["Notebook`Editor`Kernel`FrontSubmitService`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]

FrontSubmit::usage = "FrontSubmit[expr] to evaluation on frontend"
CurrentWindow::usage = ""

Begin["`Private`"]

CurrentWindow[] := Global`$EvaluationContext["KernelWebSocket"]

FrontSubmit[expr_, OptionsPattern[] ] := With[{cli = OptionValue["Window"]},
    WLJSTransportSend[expr, cli]
]

Options[FrontSubmit] = {"Window" :> Global`$EvaluationContext["KernelWebSocket"]}

End[]
EndPackage[]