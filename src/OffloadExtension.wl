BeginPackage["Notebook`Editor`OffloadExtensions`", {
    "Notebook`Editor`FrontendObject`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`WLJS`Transport`"
}]


Offload`FromEventObject[o_EventObject] := With[{view = o[[1]]["View"], sym = Unique["OffloadGenerated"]}, 
  EventHandler[o, Function[x, sym = x]] // EventFire;
  Interpretation[CreateFrontEndObject[view], Offload[sym]]
]

EndPackage[]