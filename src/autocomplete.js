core.UIAutocompleteConnect = async (args, env) => {
    server.kernel.emitt('autocomplete', 'True', 'Connect');
}

const codemirror = window.SupportedCells['codemirror'].context;

core.UIAutocompleteExtend = async (args, env) => {
    const data = await interpretate(args[0], env);
 
    
    data.forEach((element)=>{
      const name = element[0];
      const usage = element[1];
  
      if (!(name in core.UIAutocompleteExtend.symbols)) {
        codemirror.EditorAutocomplete.extend([  
          {
              "label": name,
              "type": "keyword",
              "info": usage,
              "c": true
          }]);
  
        core.UIAutocompleteExtend.symbols[name] = usage;
      }
    });
}

core["Notebook`Autocomplete`UIAutocompleteExtend"] = core.UIAutocompleteExtend


core.UIAutocompleteExtend.symbols = {};