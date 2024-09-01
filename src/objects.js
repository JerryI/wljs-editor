window.ObjectHashMap = {}
//storage for the frontend objects / executables
window.ObjectStorage = class {
    refs = {}
    uid = ''
    cached = false
    cache = []
    doNotCollect = false
  
    garbageCollect() {
      console.warn('garbage collector started...');
      let toBeRemoved = true;
      const refs = this.refs;
      Object.keys(refs).forEach((key) => {
        if (refs[key].dead) {
          delete refs[key];
        } else {
          toBeRemoved = false;
        }
      });

      if (toBeRemoved && !this.doNotCollect) {
        console.warn('No active refs. Removing...');
        delete ObjectHashMap[this.uid];
        delete this.cache;
        delete this.refs;
      }
    }         
  
    constructor(uid) {
      this.uid = uid;
      ObjectHashMap[uid] = this;
      //check garbage
      //renewGarbageTimer();
    }           
  
    //assign an instance of FrontEndExecutable to it
    assign(obj) {
      this.refs[obj.instance] = obj;
    }         
  
    //remove a reference to the instance of FrontEndExecutable
    dropref(obj) {
      console.log('dropped ref: ' + obj.instance);
      delete this.refs[obj.instance];
    }         
  
    //update the data in the storage and go over all assigned objects
    update(newdata) {
      this.cache = newdata;
      Object.keys(this.refs).forEach((ref)=>{
        //console.log('Updating... ' + this.refs[ref].uid);
        this.refs[ref].update();
      });
    }         
  
    //just get the object (if not in the client -> ask for it and wait)
    get() {
      if (this.cached) return this.cache;
      const self = this;
      //throw('Object not found!');

      let target = server;

      const promise = new Deferred();
      console.log(target);
      getObject(target, self.uid).then((result) => {
        self.cache = result;
        //console.log('resolved');
        //console.log(self.cache);
        promise.resolve(self.cache);
      }, (rejected) => {
        console.warn('Rejected! Trying evaluation server instance');
        target = server.kernel;
        
        if (typeof target != 'object') {
          console.error('Object not found on both Frontend & Evaluation Kernel: '+self.uid);
          console.warn(rejected);
          promise.reject();
          return;
        }
        
        getObject(target, self.uid).then((result) => {
            self.cache = result;
            //console.log('resolved');
            //console.log(self.cache);
            promise.resolve(self.cache);
        }, (rejected) => {
            console.error('Did not manage to get frontend object '+self.uid);
            console.warn(rejected);
            promise.reject();
        });
      })

      return promise.promise;
    }
}

//firstly ask server.kernel.ask()
//if not an object or return $Failed, ask server.ask()

//Extend Server Class
function getObject(server, id) {
    //console.log(server);
    return server.ask('Notebook`Editor`FrontendObject`GetObject["'+id+'"]'); 
}

core.FrontEndVirtual = async (args, env) => {
  const copy = {...env};
  const store = args[0];
  const instance = new ExecutableObject('fevirtual-'+uuidv4(), copy, store);
  instance.assignScope(copy);


  return await instance.execute();
}


//element will be provided in 
core.FrontEndExecutable = async (args, env) => {
    console.log('executable object');
    const uid = await interpretate(args[0], env);

    let obj;
    console.log('check cache');
    if (ObjectHashMap[uid]) {
        obj = ObjectHashMap[uid];
    } else {
        obj = new ObjectStorage(uid);
    }
    //console.log(obj);

    const copy = {...env};
    const store = await obj.get();
    const instance = new ExecutableObject('static-'+uuidv4(), copy, store, true); // STATIC
    instance.assignScope(copy);
    obj.assign(instance);

    return await instance.execute();
}

core.FrontEndExecutable.destroy = async (args, env) => {
  console.warn("Nothing to do. Will be purged automatically...");
}

//bug fix when importing an old format notebook, context gets lost
core["Global`FrontEndExecutable"] = core.FrontEndExecutable;

const garbageCollect = () => {
  const list = Object.values(ObjectHashMap);
  for (let i=0; i<list.length; i++) {
    list[i].garbageCollect();
  }  
}

core.UIObjects = async (args, env) => {
  const type = await interpretate(args[0], env);
  return core.UIObjects[type](args.slice(1), env);
}

core.UIObjects.GetAll = async (args, env) => {
  garbageCollect();
  const list = Object.values(ObjectHashMap);
  const message = [];
  for (let i=0; i<list.length; i++) {
    message.push(['Rule', "'"+list[i].uid+"'", list[i].cache]);
  }
  message.unshift('Association');
  console.log(message);
  return message;
}


core.UIObjects.GetAllSymbols = async (args, env) => {
  //garbageCollect();
  const list = Object.keys(server.kernel.trackedSymbols);
  const message = [];
  for (let i=0; i<list.length; i++) {
    if (Object.keys(core[list[i]].instances).length == 0) {
      console.warn('Dead symbol: '+list[i] + ' found!');
      continue;
    }
    message.push(['Rule', "'"+list[i]+"'", core[list[i]].data]);
  }
  message.unshift('Association');
  console.log(message);
  return message;
}

core.UIObjects.Get = async (args, env) => {
  //garbageCollect();
  //const list = Object.values(ObjectHashMap);
  const uid = await interpretate(args[0], env);
  if (ObjectHashMap[uid]) { 
    return ObjectHashMap[uid].cache;
  } else {
    console.error('UIObjects get could not find an object');
    return ['$Failed'];
  }
}