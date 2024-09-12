BeginPackage["Notebook`Editor`Rasterize`", {
  "JerryI`Misc`Events`", 
  "JerryI`Misc`Events`Promise`", 
  "Notebook`EditorUtils`",
  "Notebook`Editor`Kernel`FrontSubmitService`"
}]

Begin["`Internal`"]

Unprotect[Rasterize]
ClearAll[Rasterize]

Rasterize[n_Notebook, opts___] := Block[{Internal`RasterizeOptionsProvided = opts},
  Switch[n // First // First//First//First//Head,
    GraphicsBox,
      ToExpression[n // First // First // First, StandardForm],

    ImageBox,
      ToExpression[n // First // First // First, StandardForm],      

    GraphicsBox3D,
      ToExpression[n // First // First // First, StandardForm],
    _,

    Print["Not supported directly. Please, apply Rasterize before exporting as an image"];
    Return[];
    
  ]
]

Notebook`Editor`Rasterize`Internal`OverlayView;

Rasterize[any_, ___, OptionsPattern[] ] := With[{p = Promise[], channel = CreateUUID[], window = OptionValue["Window"]},
  EventHandler[channel, Function[Null,
    Then[FrontFetchAsync[OverlayView["Capture"], "Window" -> window], Function[base,
      EventFire[p, Resolve, ImportString[StringDrop[base, StringLength["data:image/png;base64,"] ], "Base64"] ];
      FrontSubmit[OverlayView["Dispose"], "Window" -> window];
    ] ]
  ] ];

  FrontSubmit[OverlayView["Create", EditorView[ToString[any, StandardForm] ], channel], "Window" -> window];

  WaitAll[p]
]

Options[Rasterize] = {"Window" :> CurrentWindow[]}

End[]
EndPackage[]