core.SetKernelDirectory = async (args, env) => {
    const path = await interpretate(args[0], env);
    const event = await interpretate(args[1], env);

    window.addEventListener("focus", () => {
        if (!server.kernel) return;
        server.kernel.emitt(event, '"'+path+'"');
    });
}