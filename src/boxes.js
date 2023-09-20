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
            
          console.error('g2d: RGBColor must have three arguments!');
        }

        return undefined;
    }
}