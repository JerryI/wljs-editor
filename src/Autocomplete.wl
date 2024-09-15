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

defaults = Get[FileNameJoin[{rootDir, "src", "AutocompleteDefaults.wl"}] ];

EventHandler[AppExtensions`AppEvents// EventClone, {
    "Loader:NewNotebook" ->  (Once[ attachListeners[#] ] &),
    "Loader:LoadNotebook" -> (Once[ attachListeners[#] ] &)
}];


GetDefaults := With[{},
    <|"hash" -> Hash[defaults], "data" -> defaults|>
]


attachListeners[notebook_Notebook] := With[{},
    Echo["Attach event listeners to notebook from EXTENSION"];
    EventHandler[notebook // EventClone, {
        "OnWebSocketConnected" -> Function[payload,
            Kernel`Init[notebook["Evaluator"]["Kernel"], Unevaluated[
                Notebook`Autocomplete`Private`BuildVocabular;
                Notebook`Autocomplete`Private`StartTracking;
            ], "Once"->True];
         

            WebUISubmit[ Global`UIAutocompleteConnect[Hash[defaults] ], payload["Client"] ];
        ]
    }]; 
]

docsFinder[request_] := With[{
    name = If[StringTake[#, -1] == "/", StringDrop[#, -1], #] &@ (StringReplace[request["Path"], ___~~"/docFind/"~~(n:__)~~EndOfString :> n])
},
    With[{url = Information[name]["Documentation"]//First},
        If[StringQ[url],
            StringTemplate["<body><div style=\"height: 2rem;width: 100%;-webkit-app-region: drag;-webkit-user-select: none;\"></div><iframe style=\"width:100%;height:calc(100% - 2rem);border: none;border-radius: 7px; background: transparent;\" src=\"``\"></iframe></body>"][url]
        ,
            StringTemplate["<body><div style=\"height: 2rem;width: 100%;-webkit-app-region: drag;-webkit-user-select: none;\"></div><div style=\"padding:1rem; margin-top:2rem;\">Undocumented symbol ``</div></body>"][url]
        ]
        
    ]
]

With[{http = AppExtensions`HTTPHandler},
    http["MessageHandler", "DocsFinder"] = AssocMatchQ[<|"Path" -> ("/docFind/"~~___)|>] -> docsFinder;
];


End[]
EndPackage[]