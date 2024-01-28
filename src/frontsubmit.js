core.FSAskKernelSocket = async (args, env) => {
    return await server.kernel.ask('Global`$Client');
}