BeginPackage["Notebook`Editor`Autocomplete`", {
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`", 
    "JerryI`Notebook`", 
    "JerryI`WLX`WebUI`", 
    "JerryI`Notebook`AppExtensions`",
    "JerryI`Notebook`Kernel`",
    "KirillBelov`HTTPHandler`",
    "KirillBelov`HTTPHandler`Extensions`",
    "KirillBelov`Internal`"
}]

Begin["`Private`"]

rootDir = $InputFileName // DirectoryName // ParentDirectory;

EventHandler[AppExtensions`AppEvents// EventClone, {
    "Loader:NewNotebook" ->  (Once[ attachListeners[#] ] &),
    "Loader:LoadNotebook" -> (Once[ attachListeners[#] ] &)
}];

attachListeners[notebook_Notebook] := With[{},
    Echo["Attach event listeners to notebook from EXTENSION"];
    EventHandler[notebook // EventClone, {
        "OnWebSocketConnected" -> Function[payload,
            Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                Notebook`Autocomplete`Private`BuildVocabular;
                Notebook`Autocomplete`Private`StartTracking;
            ], "Once"->True];
         

            WebUISubmit[ Global`UIAutocompleteConnect[], payload["Client"] ];
        ]
    }]; 
]

docsFinder[request_] := With[{
    name = If[StringTake[#, -1] == "/", StringDrop[#, -1], #] &@ (StringReplace[request["Path"], ___~~"/docFind/"~~(n:__)~~EndOfString :> n])
},
    With[{url = Information[name]["Documentation"]//First},
        If[StringQ[url],
            StringTemplate["<iframe style=\"width:100%;height:100%;border: none;border-radius: 7px; background: transparent;\" src=\"``\"></iframe>"][url]
        ,
            StringTemplate["<div style=\"padding:1rem; margin-top:2rem;\">Undocumented symbol ``</div>"][url]
        ]
        
    ]
]

With[{http = AppExtensions`HTTPHandler},
    http["MessageHandler", "DocsFinder"] = AssocMatchQ[<|"Path" -> ("/docFind/"~~___)|>] -> docsFinder;
];


End[]
EndPackage[]