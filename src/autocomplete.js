const codemirror = window.SupportedCells['codemirror'].context;

core.UIAutocompleteConnect = async (args, env) => {
    console.log('Autocomplete connected to a server');
    const hash = await interpretate(args[0], env);
    //const channel = await interpretate(args[1], env);

    //check the store
    if (localStorage.getItem("codemirror-autocomplete-hash") != String(hash)) {
      let completeInfo = await server.ask('Notebook`Editor`Autocomplete`Private`GetDefaults');
      completeInfo = await interpretate(completeInfo, env);
      console.warn('Update static autocomplete info');
      console.warn(completeInfo);
      localStorage.setItem("codemirror-autocomplete-hash", String(completeInfo.hash));
      localStorage.setItem("codemirror-autocomplete", JSON.stringify(completeInfo.data));
      codemirror.EditorAutocomplete.replaceAll(completeInfo.data);
    } else {
      codemirror.EditorAutocomplete.replaceAll(JSON.parse(localStorage.getItem("codemirror-autocomplete")));
    }

    server.kernel.emitt('autocomplete', 'True', 'Connect');
}

core.UIAutocompleteExtend = async (args, env) => {
    const data = await interpretate(args[0], env);
    console.log('Autocomplete populate');
    //console.log(data);
    
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