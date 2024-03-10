import {
    EditorView,
    Decoration,
    ViewPlugin
  } from "@codemirror/view";


  const transferFiles = (list, ev, view, handler) => {
    if (list.length == 0) return;
    const id = new Date().valueOf();
    let count = 0;

    const progress = (num) => {
        
    };

    progress(0);
    handler.transaction(ev, view, id, list.length);
   // server.kernel.emitt('<Event/>', `<|"Id" -> "${id}", "Length" -> ${list.length}|>`, 'Transaction');
    
    for (const file of list) {
        readFile(file, (name, result) => {
            handler.file(ev, view, id, name, result);
            //server.kernel.emitt('id', `<|"Transaction" -> "${id}", "Name" -> "${name}", "Data" -> "${result}"|>`, 'File');
            count++;
            progress(count);
        })
    }
    
}

function readFile(file, cbk) {
    const reader = new FileReader();
    reader.addEventListener('load', (event) => {
      let compressedData = base64ArrayBuffer(event.target.result);
      //console.log(compressedData);
      cbk(file.name, compressedData);  
    });
  
    reader.addEventListener('progress', (event) => {
      if (event.loaded && event.total) {
        const percent = (event.loaded / event.total) * 100;
        console.log(percent);
      }
    });

    reader.readAsArrayBuffer(file);
}


//drag and drop and past events
export const DropPasteHandlers = (hd) => EditorView.domEventHandlers({
	drop(ev, view) {
        //console.log("codeMirror :: paste ::", ev); // Prevent default behavior (Prevent file from being opened)
        ev.preventDefault();

        const filesArray = [];

        if (ev.dataTransfer.items) {
            // Use DataTransferItemList interface to access the file(s)
            [...ev.dataTransfer.items].forEach((item, i) => {
                // If dropped items aren't files, reject them
                if (item.kind === "file") {
                    const file = item.getAsFile();
                    console.log(`… file[${i}].name = ${file.name}`);
                    filesArray.push(file);
                }
            });
        } else {
            // Use DataTransfer interface to access the file(s)
            [...ev.dataTransfer.files].forEach((file, i) => {
                console.log(`… file[${i}].name = ${file.name}`);
                filesArray.push(file);
            });
        }

        transferFiles(filesArray, ev, view, hd);

    },

    paste() {

    }
})

