{
  let boxes = {};
  boxes.name = "WebObjects/Boxes";

  interpretate.contextExpand(boxes);

  boxes.NumberMarks = () => "NumberMarks"
  boxes.ShowStringCharacters = () => "ShowStringCharacters"

  boxes.Background = () => "Background"

  boxes.RowBox = async (args, env) => {
    console.log(args);
  }

  boxes.ProvidedOptions = async (args, env) => {
    env.options = await core._getRules(args.slice(1), env);
    return await interpretate(args[0], env);
  }

  boxes.FrameBox = async (args, env) => {
      env.element.classList.add('frame-box');
      env.context = boxes;

      const options = await core._getRules(args, env) || {};
      
      if ('Background' in options) {
          env.element.style.backgroundColor = options.Background;
      }
  }

  boxes.StyleBox = async (args, env) => {
      env.context = boxes;
      console.log('style box');
      
      console.log(args);

      const options = await core._getRules(args, env) || {};
      
      if ('Background' in options) {
          env.element.style.backgroundColor = options.Background;
      }        
  }

  boxes.DateObjectTemplate = async (args, env) => {
      const element = document.createElement('span');
      element.class = "";
      element.style.paddingLeft = "1em";
      element.style.paddingRight = "1em";
      element.style.border = "1px solid gray";
      element.style.borderRadius = "4px";
      element.style.fontSize = "x-small";

      //env.element.classList.add('frame-box');
      env.context = boxes;

      const date = await interpretate(args[0], env);
      element.innerText = date.slice(1,-1); 
      env.element.appendChild(element);
  }

  boxes.RGBColorSwatchTemplate = async (args, env) => {
      const element = document.createElement('span');

      element.class = "";
      element.style.width = "1em";
      element.style.height = "1em";
      element.style.border = "1px solid gray";
      element.style.borderRadius = "4px";

      //env.element.classList.add('frame-box');
      env.context = boxes;

      const color = await interpretate(args[0], env);
      element.style.backgroundColor = color;

      env.element.appendChild(element);
  }

  boxes.Opacity = async (args, env) => {
      return (await interpretate(args[0], env));
  }
  
  boxes.RGBColor = async (args, env) => {
      if (args.length == 3) {
        const r = (await interpretate(args[0], env)) * 255;
        const g = (await interpretate(args[1], env)) * 255;
        const b = (await interpretate(args[2], env)) * 255;

        return "rgb("+r+","+g+","+b+")";
      } else {
        let a = await interpretate(args[0], env);

        a = a.map((e) => e*255);

        return "rgb("+a[0]+","+a[1]+","+a[2]+")";
      }

      return undefined;
  }

  /*boxes.PaneSelectorBox = async (args, env) => {
      const list = await interpretate(args[0], {...env, hold:true});
      //needs an editor View
      env.element.innerText = "EditorView is in development";
      env.element.style.border = "1px solid gray";
      env.element.style.borderRadius = "4px";
  }*/

  boxes.DynamicModuleBox = async (args, env) => {
      return await interpretate(args[1], {...env, context: boxes});
    }
    
    boxes.PaneSelectorBox = async (args, env) => {
      const list = await interpretate(args[0], {...env, hold:true});
      //env.element.innerText = data.slice(1,-1);
      env.element.style.paddingLeft = "0.5em";
      env.element.style.paddingRight = "0.5em";
      env.element.style.borderRadius = "4px";
      env.element.style.border = "1px solid gray";
      env.element.style.verticalAlign = "initial";

      const data = await interpretate(list[0][2], env);

      env.element.innerText = data.flat().join(',').slice(1,-1);
    }

    boxes.CM6Grid = async (args, env) => {
      console.warn('this is an temporal fallback to boxes CM6Grid virtual type! Be careful!');
      const data = await interpretate(args[0], env);
      return data;
    }
    
    boxes.GridBox = async (args, env) => {
      return await interpretate(args[0], env);
    }
    
    boxes.TagBox = async (args, env) => {
      const name = await interpretate(args[1], env);
      const data = await interpretate(args[0], env);
      const doc = document.createElement('div');
      const result = await boxes.TagBox[name](data, {...env, element:doc});
      env.element.appendChild(doc);
      return result;
    }
    
    boxes.TagBox['SummaryItem'] = async (data, env) => {
      env.element.innerText = data.slice(1,-1);
      env.element.style.paddingLeft = "0.5em";
      env.element.style.paddingRight = "0.5em";
      env.element.style.borderRadius = "4px";
      env.element.style.border = "1px solid gray";
      env.element.style.verticalAlign = "initial";
    }


    boxes.BraDecorator = async (args, env) => {
      const pre = document.createElement('span');
      const post = document.createElement('span');
    
      post.innerHTML = "|";
      pre.innerHTML = "&#10216;";
    
      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
    
      env.element.appendChild(pre);
      env.element.appendChild(editor);
      env.element.appendChild(post);
    }
    
    boxes.KetDecorator = async (args, env) => {
      const pre = document.createElement('span');
      const post = document.createElement('span');
    
      pre.innerHTML = "|";
      post.innerHTML = "&#10217;";
    
      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
    
      env.element.appendChild(pre);
      env.element.appendChild(editor);
      env.element.appendChild(post);
    }

    boxes.FrameMargins = () => "FrameMargins"

    boxes.PanelBox = async (args, env) => {   
      const options = await core._getRules(args, {...env, context: boxes});
      let margin = 0.7; 
      
      if (options.FrameMargins) margin = Math.round(10.0 * options.FrameMargins / 10.0)/10.0;

      const editor = document.createElement('span');
      env.global.element = editor;
    
      env.element.style.display = "inline-flex";
      env.element.style.alignItems = "baseline";
      env.element.style.padding = margin + "em";

      env.element.style.borderRadius = "4px";
      env.element.style.border = "solid 1px";
      env.element.style.background = "#f0f0f0";

      env.element.appendChild(editor); 
    }

}

