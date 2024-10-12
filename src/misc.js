core['Notebook`Editor`Rasterize`Internal`OverlayView'] = async (args, env) => {
    const cmd = await interpretate(args[0], env);
    const result = await core['Notebook`Editor`Rasterize`Internal`OverlayView'][cmd](args.slice(1), env);
    return result;
}

let overlay = undefined;

core['Notebook`Editor`Rasterize`Internal`OverlayView'].Dispose = async (args, env) => {
    if (overlay) await overlay.dispose();
}

core['Notebook`Editor`Rasterize`Internal`OverlayView'].Capture = async (args, env) => {
    if (!electronAPI?.requestScreenshot) {
        if (overlay) await overlay.dispose();
        throw('Not supported outside Electron (aka Desktop App)');
    }

    const p = new Deferred();

    const rect = overlay.dom.getBoundingClientRect();
    console.warn(rect);

    electronAPI.requestScreenshot({y:Math.round(rect.top+2), x:Math.round(rect.left+2), width: Math.round(rect.width-4), height: Math.round(rect.height-4)}, (r) => {
        p.resolve(r);
    });

    return p.promise;
}

core['Notebook`Editor`Rasterize`Internal`OverlayView'].Create = async (args, env) => {
    if (overlay) await overlay.dispose();
    
    const overlay_div = document.createElement('div');
    overlay_div.classList.add('w-full', 'h-full', 'flex');
    overlay_div.style.backgroundColor = 'rgb(107 114 128 / 0.5)';

    const container = document.createElement('div');
    container.classList.add('mt-auto', 'mb-auto', 'ml-auto', 'mr-auto', 'bg-white', 'rounded', 'p-1');

    overlay_div.appendChild(container);
    env.element = container;

    document.body.prepend(overlay_div);
    
    overlay = {
        env: env,
        dom: container,
        dispose: async () => {
            for (const obj of Object.values(overlay.env.global.stack))  {
                obj.dispose();
            }

            console.log('OverlayView disposed!');

            overlay_div.remove();
            overlay = undefined
        }
    };

    await interpretate(args[0], env);

    const channel = interpretate(args[1], env);

    setTimeout(() => {
        server.kernel.emitt(channel, 'True');
    }, 1000);
}

core.SystemOpen = async (args, env) => {
    const type = await interpretate(args[1], env);
    await core.SystemOpen[type](args[0], env);
}

core.SystemOpen.File = async (path, env) => {
    const p = await interpretate(path, env);
    window.electronAPI.openPath(p);
}

core.SystemOpen.Folder = async (path, env) => {
    const p = await interpretate(path, env);
    window.electronAPI.openFolder(p);
}

core.SystemOpen.URL = async (path, env) => {
    const p = await interpretate(path, env);
    window.electronAPI.openExternal(p);
}






