BeginPackage["Notebook`Utils`Notifications`", {"JerryI`Misc`Events`", "JerryI`Misc`Events`Promise`", "Notebook`CellOperations`"}]

Notify::usage = "Notify[message_, args__, opts] prints a message in a notification box"

HapticFeedback::usage = "HapticFeedback[] make a haptic feedback on MacOS devices (Desktop App only)"

Begin["`Private`"]

notRule[_Rule] = False
notRule[_] = True

Unprotect[Beep]
ClearAll[Beep]
Beep[]  := EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`Beeper[], True]; 
Beep[_] := Beep[]


HapticFeedback[]  := EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`Rumble[], True]; 
HapticFeedback[_] := HapticFeedback[]

Notify[template_String, args__?notRule, OptionsPattern[] ] := With[{
    message = StringTemplate[template][args]
},
    EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`NotificationMessage[OptionValue["Topic"] ], message]; 
]

Notify[template_String, OptionsPattern[] ] := With[{
    message = template
},
    EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`NotificationMessage[OptionValue["Topic"] ], message]; 
]

Notify[template_, OptionsPattern[] ] := With[{
    message = ToString[template]
},
    EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`NotificationMessage[OptionValue["Topic"] ], message]; 
]

Notify`CreateModal[name_String, data_Association, OptionsPattern[] ] := Module[{}, With[{p = Promise[], promise = Promise[], proxy = Unique["modalContainer"]},
    EventFire[Internal`Kernel`CommunicationChannel, "CreateModal", <|
            "Notebook"->First[OptionValue["Notebook"]], 
            "Ref"->Global`$EvaluationContext["Ref"], 
            "Promise" -> (promise), 
            "Kernel"->Internal`Kernel`Hash,
            "Modal" -> name,
            "Data"->data
    |>];

    Then[promise, Function[result,
        EventRemove[proxy];
        ClearAll[proxy];

        EventFire[p, Resolve, result];
    ] ];
    
    p
] ]

Options[Notify`CreateModal] = {"Notebook" :> RemoteNotebook[ Global`$EvaluationContext["Notebook"] ] }


Options[Notify] = {"Topic" -> "Kernel"}

End[]
EndPackage[]
