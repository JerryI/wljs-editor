window.EditorAutocomplete.extend([  
    {
        "label": "ViewBox",
        "type": "keyword",
        "info": "ViewBox[expr_, decorator_] low-level box used by InterpretationBox. It keeps `expr` in its original form, while visially covers it with DOM element to which `decorator` expression will be attached and executed"
    },
    {
        "label": "BoxBox",
        "type": "keyword",
        "info": "BoxBox[expr_Box | _String, decorator_] low-level box used by Style, Framed... It places a subeditor with `expr` inside and decorates the container using `decorator` expression will be attached and executed."
    },    
    {
        "label": "MiddlewareHandler",
        "type": "keyword",
        "info": "MiddlewareHandler[exp, \"type\"->handler, opts...] captures event from container"
    }       
])

console.log('loaded!');