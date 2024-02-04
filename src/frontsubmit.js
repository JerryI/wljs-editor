core.FSAskKernelSocket = async (args, env) => {
    return await server.kernel.ask('Global`$Client');
}

core.FSAsk = async (args, env) => {
    const result = await interpretate(args[0]);
    const uid = await interpretate(args[1]);
    console.warn("A request from kernel server");
    //console.log(result);
    //console.log(JSON.stringify(result));

    server.kernel.emitt(uid, '"' + encodeURIComponent(JSON.stringify(result)) + '"');
}