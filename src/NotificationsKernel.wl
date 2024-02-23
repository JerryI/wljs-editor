BeginPackage["Notebook`Utils`Notifications`", {"JerryI`Misc`Events`"}]

Notify::usage = "Notify[message_, args__, opts] prints a message in a notification box"
NotificationSpinner::usage = "NotificationSpinner[message_, \"Topic\"->] _Promise"

Begin["`Private`"]

notRule[_Rule] = False
notRule[_] = True

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

Options[Notify] = {"Topic" -> "Kernel"}

NotificationSpinner[message_, OptionsPattern[] ] := With[{},
    (*EventFire[Internal`Kernel`Stdout[ Internal`Kernel`Hash ], Notifications`NotificationMessage[OptionValue["Topic"] ], message];*)
    "In development..."
]

End[]
EndPackage[]
