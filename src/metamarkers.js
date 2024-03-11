//helps to find instance from server
const MetaMarkers = {};

core.MetaMarker = async (args, env) => {
  if (env.hold) {
    console.log('Held meta-marker expression!');
    return ["MetaMarker", ...args];
  }

  const marker = await interpretate(args[0], env);
  const inst = env.root.instance;

  console.log('instance '+inst+'is marked as '+marker);
  if (marker in MetaMarkers) {
    MetaMarkers[marker][inst] = env;
  } else {
    MetaMarkers[marker] = {};
    MetaMarkers[marker][inst] = env;
  }

  return null;
}

core.MetaMarker.update = (args, env) => {
  //void
}

core.MetaMarker.destroy = async (args, env) => {
  const marker = await interpretate(args[0], env);
  console.log('dispose marker for instance '+env.root.instance);
  //console.log('in the context');
  //console.log(env);
  //console.log(MetaMarkers[marker]);

  delete MetaMarkers[marker][env.root.instance];
}  

core.FindMetaMarker = async (args, env) => {
  const marker = await interpretate(args[0], env);

  if (marker in MetaMarkers) {
    console.log('found one!');
    const arr =  Object.values(MetaMarkers[marker]);
    const list = arr.map((el) => {
      return ['MetaMarkers', el]
    });

    //console.log('list of markers');
    //console.log(list);

    return list;
  }

  return null;
}

core.MarkerContainer = async (args, env) => {
    const expr = args[0];
    const marker = await interpretate(args[1], {...env, hold:true});

    if (marker[0] !== 'MetaMarker') 
        throw 'Last argument is not a MetaMarker object!';
    
    const uid = await interpretate(marker[1], env);
    const results = [];

    if (uid in MetaMarkers) {
      console.log('found Marker');
      const arr =  Object.values(MetaMarkers[uid]);
      
      for (const instance of arr) {

        //execute inside the container
        console.log('try!');

        if (instance.root.dead) {
          console.log('instance is dead!');
          delete MetaMarkers[uid][instance.root.instance];
          continue;
        }
        //console.log(instanceEnv);
        const copy = {...instance};
  
        //merge the scope
        copy.scope = {...copy.scope, ...env.scope};
  
        //if sleeping?
        if (copy.wake) copy.wake();

        const result = await interpretate(expr, copy);
        results.push(result);
      }
    }  
  
    return results;    
}

//IN DEVELOPMENT!!!!
//IN DEVELOPMENT!!!!
//IN DEVELOPMENT!!!!
//IN DEVELOPMENT!!!!
const contrainersBox = {};

core.DeleteExecutablesBox = async (args, env) => {
  let containersBoxIDs =  await interpretate(args[0], env);
  if (!containersBoxIDs.length) containersBoxIDs = [containersBoxIDs];

  containersBoxIDs.forEach((e) => {
    console.log("disposing object...");
    e.dispose();
  })
  //somehow remove them
}


//a much more complicated version, where you are using object to return
core.MarkerContainerExtended = async (args, env) => {
  if (args.length < 3) {
    console.log('MarkerContainerExtended cannot be evaluated on the frontend with only 2 argument!');
    throw 'MarkerContainerExtended cannot be evaluated on the frontend with only 2 argument!';
  }

  const expr = args[0];

  //where this thing will be placed
  //to omitt communication between WLJS and WL
  const containersBoxID =  await interpretate(args[2], env);

  const Box = [];

  //CORRENTLY SUPPORTS ONLY METAMARKER OBJECTS
  const marker = await interpretate(args[1], {...env, hold:true});

  if (marker[0] !== 'MetaMarker') {
    throw 'FrontSubmit cannot be evaluated on the frontend with only MetaMarker as a second argument';
  }

  const uid = await interpretate(marker[1], env);
  const results = [];

  if (uid in MetaMarkers) {
    console.log('found one! ');
    const arr =  Object.values(MetaMarkers[uid]);
    
    for (const instance of arr) {
      //execute inside the container
      console.log('try!');
      //console.log(instanceEnv);
      const copy = {...instance};

      //merge the scope
      copy.scope = {...copy.scope, ...env.scope};
      if (!copy.global.hooks) copy.global.hooks = [];
      copy.global.hooks.push((obj)=>{
        Box.push(obj);
      });

      const result = await interpretate(expr, copy);

      results.push(result);
    }
  }  

  contrainersBox[containersBoxID] = Box;
  return results;
}
