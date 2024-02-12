core.SetKernelDirectory = async (args, env) => {
    const path = await interpretate(args[0], env);
    const event = await interpretate(args[1], env);

    window.addEventListener("focus", () => {
        if (!server.kernel)  {
            return;
        }
        if (server.kernel.socket.readyState != 1) {
            return;
        }
        server.kernel.emitt(event, '"'+path+'"');
    });

    let caller;
    
    caller = () => setTimeout(() => {
        if (!server.kernel) {
            caller();
            return;
        };
        if (server.kernel.socket.readyState != 1) {
            caller();
            return;
        }
        server.kernel.emitt(event, '"'+path+'"');
        caller = () => {};
    }, 300);

    caller();

}