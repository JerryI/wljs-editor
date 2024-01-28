window.ObjectHashMap = {}
//storage for the frontend objects / executables
window.ObjectStorage = class {
    refs = {}
    uid = ''
    cached = false
    cache = []
  
    garbageCollect() {
      console.warn('garbage collector is not defined for');
      console.warn(this);
  
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

//element will be provided in 
core.FrontEndExecutable = async (args, env) => {
    console.log('forntend executable');
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
    const instance = new ExecutableObject('stored-'+uuidv4(), copy, store);
    instance.assignScope(copy);
    obj.assign(instance);

    return await instance.execute();
}

core.UIObjects = async (args, env) => {
  const type = await interpretate(args[0], env);
  return core.UIObjects[type](args.slice(1), env);
}

core.UIObjects.GetAll = async (args, env) => {
  const list = Object.values(ObjectHashMap);
  const message = [];
  for (let i=0; i<list.length; i++) {
    message.push(['Rule', "'"+list[i].uid+"'", list[i].cache]);
  }
  message.unshift('Association');
  console.log(message);
  return message;
}