BeginPackage["Notebook`Editor`FrontendObject`MissingFetcher`", {
    "Notebook`Editor`FrontendObject`",
    "Notebook`Editor`Kernel`FrontSubmitService`"  
}]

Begin["`Internal`"]

(* if doen't exists, try to fetch it from an active Window *)
Notebook`Editor`FrontendObject`Internal`$MissingHandler[uid_String, "Private"] := With[{win = CurrentWindow[]},
    With[{result = FrontFetch[Global`UIObjects["Get", uid], "Window"->win, "Format"->"ExpressionJSON"]},
        If[FailureQ[result],
            $Failed
        ,
            (* cache it *)
            Notebook`Editor`FrontendObject`Objects[uid] = <|"Private" -> result, "Public" :> (Notebook`Editor`FrontendObject`Objects[uid, "Private"])|>;
            result
        ]
    ]
]


End[]
EndPackage[]