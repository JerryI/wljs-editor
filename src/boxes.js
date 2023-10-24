{
    let boxes = {};
    boxes.name = "WebObjects/Boxes";
  
    interpretate.contextExpand(boxes);

    boxes.Background = () => "Background"
  
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
        env.element.class = "";
        env.element.style.paddingLeft = "1em";
        env.element.style.paddingRight = "1em";
        env.element.style.border = "1px solid gray";
        env.element.style.borderRadius = "4px";
        env.element.style.fontSize = "x-small";

        //env.element.classList.add('frame-box');
        env.context = boxes;

        const date = await interpretate(args[0], env);
        env.element.innerText = date.slice(1,-1); 
    }

    boxes.RGBColorSwatchTemplate = async (args, env) => {
        env.element.class = "";
        env.element.style.width = "1em";
        env.element.style.height = "1em";
        env.element.style.border = "1px solid gray";
        env.element.style.borderRadius = "4px";

        //env.element.classList.add('frame-box');
        env.context = boxes;

        const color = await interpretate(args[0], env);
        env.element.style.backgroundColor = color;
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
        return await boxes.TagBox[name](data, env);
      }
      
      boxes.TagBox['SummaryItem'] = async (data, env) => {
        env.element.innerText = data.slice(1,-1);
        env.element.style.paddingLeft = "0.5em";
        env.element.style.paddingRight = "0.5em";
        env.element.style.borderRadius = "4px";
        env.element.style.border = "1px solid gray";
        env.element.style.verticalAlign = "initial";
      }

}