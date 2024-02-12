

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

End[]

FrontSubmit[expr_, m_MetaMarker, OptionsPattern[] ] := With[{cli = OptionValue["Window"]},
    WLJSTransportSend[MarkerContainer[expr, m], cli]
]

EndPackage[]