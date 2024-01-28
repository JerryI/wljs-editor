BeginPackage["Notebook`Autocomplete`", {
    "KirillBelov`WebSocketHandler`",
    "JerryI`Misc`WLJS`Transport`",
    "JerryI`Misc`Events`",
    "JerryI`Misc`Events`Promise`",
    "JerryI`Misc`Async`"
}];

UIAutocompleteExtend;

Begin["`Private`"]

definitions = {};
clients = {};

shareDefinitions[cli_, set_List] := With[{
    data = set
},
    If[FailureQ @ WebSocketSend[cli, ExportByteArray[UIAutocompleteExtend[data], "ExpressionJSON"] ], clients = clients /. {cli -> Nothing}];
]

EventHandler["autocomplete", {
    "Connect" -> Function[Null,
        With[{client = Global`$Client},
            clients = Append[clients, client];
            Echo["Autocomplete  >> New connection!"];
            If[Length[definitions] != 0,
                shareDefinitions[client, definitions];
            ];
        ]     
    ]
}];

extend[set_] := shareDefinitions[#, set] &/@ clients;

(* a bug with a first defined symbol $InterfaceEnvironment that causes shutdown (BUT THIS IS A STRING!!!). No idea why *)
skip = 1;

blacklist = {"Notebook`Autocomplete`", "KirillBelov`LTP`JerryI`Events`","KirillBelov`CSockets`EventsExtension`","JerryI`Misc`WLJS`Transport`","KirillBelov`WebSocketHandler`","KirillBelov`TCPServer`","KirillBelov`LTP`","KirillBelov`Internal`","KirillBelov`CSockets`","HighlightingCompatibility`","System`","Global`"};

BuildVocabular := With[{},
    BuildVocabular = Null;
    With[{r = Flatten[( {#, Information[#, "Usage"]} &/@ Names[#<>"*"] ) &/@ Complement[$ContextPath, blacklist], 1]},
        definitions = Join[definitions, r] // DeleteDuplicates;
    ];
]

StartTracking := (
    StartTracking = Null;
    If[Internal`Kernel`Type =!= "LocalKernel",
        Echo["Error. Autocomplete package can only for on LocalKernel. MasterKernel is not allowed!"];
    ,
        Echo["Tracking of symbols has been started!"];
        SetTimeout[
        $NewSymbol = If[#2 === "Global`", (
            If[skip > 0,
                skip--;
            ,
                definitions = Append[definitions, {#1, "User's defined symbol"} ]; 
                extend[{{#1, "User's defined symbol"}}];
            ];
        )]&;
        , 5000];
    ];
)

End[]

EndPackage[]



