import {
  EditorView,
  Decoration,
  ViewPlugin,
  WidgetType,
  MatchDecorator
} from "@codemirror/view";
import { isCursorInside } from "./utils";

import { Mma } from "mma-uncompress/src/mma";

import { BallancedMatchDecorator2, matchArguments } from "./matcher";

import { keymap } from "@codemirror/view";
 
import { EditorSelection } from "@codemirror/state";

import { Balanced } from "node-balanced";

var compactCMEditor; 

const uuidv4 = () => { 
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
    var r = Math.random() * 16 | 0, v = c == 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

export function TemplateBoxWidget(viewEditor) {
  compactCMEditor = viewEditor;
  return [
    //mathematicaMathDecoration,
    placeholder
  ];
}

class EditorWidget {

  constructor(visibleValue, view, span, ref) {
    this.view = view;
    this.visibleValue = visibleValue;

    this.args = matchArguments(visibleValue.str, /\(\*\|\*\)/gm);

    const self = this;
    

    //ref.push(self);
    //console.log(visibleValue);

    


    const indexes = Array.from({ length: Math.ceil((self.args.length - 3)  / 2) }, (v, i) => i * 2 + 1)
    self.indexes = indexes;

    const spans = [];
    for (let i=0; i<indexes.length; ++i) {
      spans.push(document.createElement('span'));
    }
  
    
    const string = this.args[this.args.length - 1].body.slice(2,-2);
  
    const decoded = Mma.DecompressDecode(string);
    const json = Mma.toArray(decoded.parts[0]);

    this.data = json;

    const cuid = uuidv4();
    let global = {call: cuid, element: span, children: spans, origin: self};
    let env = {global: global, element: span, children: spans}; //Created in CM6
    this.env = env;

    

    interpretate(json, env).then(() => {
      

      if (env.options?.Event) {
        console.warn('Event listeners are enabled!');
        self.events = env.options.Event;
      }      



      self.editors = indexes.map((index, i) => compactCMEditor({
        doc: self.args[index].body,
        parent: spans[i],
        update: (upd) => this.applyChanges(upd, index),
        eval: () => {
          view.viewState.state.config.eval();
        },
        extensions: [
          keymap.of([
            { key: "ArrowLeft", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to) {
                if (i > 0) {
                  self.editors[i - 1].focus();
                } else {
                  view.dispatch({selection: {anchor: self.visibleValue.pos}});
                  view.focus();
                }
                editor.editorLastCursor = undefined;
                return;
              }
          
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } }, 
            { key: "ArrowRight", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to) {
                if (i < indexes.length - 1) {
                  self.editors[i + 1].focus();
                } else {
                  view.dispatch({selection: {anchor: self.visibleValue.pos + self.visibleValue.length}});
                  view.focus();
                }
                editor.editorLastCursor = undefined;
                return;
              }
                
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } }
          ])
        ]
      }));

      if(self.events) server.kernel.emitt(self.events, 'Null', 'Mounted');  

    });

  }

  applyChanges(update, index) {
      const args = this.args;
      const relative = this.visibleValue.argsPos;
  
      console.log(args);

      const changes = {from: relative + args[index].from, to:relative + args[index].from + args[index].length, insert: update};

      const delta = update.length - args[index].length;
      args[index].length = update.length;
      for (let i = index + 1; i < args.length; ++i)
        args[i].from = args[i].from + delta

      this.visibleValue.length += delta;
      this.view.dispatch({changes: changes});
  }    

  update(visibleValue) {
    //console.log('Update instance: new ranges & arguments');
    this.visibleValue.pos = visibleValue.pos;
    this.visibleValue.argsPos = visibleValue.argsPos;
  }

  destroy() {
    console.warn('destroy Instance of Widget');
    console.log(this);
    if (this.env.global.stack) {
      for (const obj of Object.values(this.env.global.stack))  {
        obj.dispose();
      }
    }  
    this.editors.forEach((i)=>i.destroy());

    if(this.events) server.kernel.emitt(this.events, 'Null', 'Destroy');

    delete this.data;
  }
}

class Widget extends WidgetType {
  constructor(visibleValue, ref, view) {
    super();
    this.view = view;
    this.visibleValue = visibleValue;
    this.reference = ref;
    //console.log('construct');
  }

  eq(other) {
    return false;
    return this.visibleValue.str === other.visibleValue.str;
  }

  updateDOM(dom, view) {
    //console.log(this.visibleValue);
    //console.log(this);
    this.DOMElement = dom;
    console.log('update widget DOM');
    dom.EditorWidget.update(this.visibleValue);

    return true
  }

  toDOM(view) {
    console.log('Create a new one!');

    let span = document.createElement("span");
    span.classList.add("inline-flex");

    span.EditorWidget = new EditorWidget(this.visibleValue, view, span, []);

    const self = this;

    this.DOMElement = span;
    
    this.reference.push({destroy: () => {
      self.destroy(span);
    }});      


    return span;
  }

  skipPosition(pos, oldPos, selected) {
    if (oldPos.from != oldPos.to || selected) return pos;

    const editors = this.DOMElement.EditorWidget.editors;
    if (pos.from - oldPos.from < 0) {
      editors[editors.length - 1].dispatch({selection: {anchor: editors[editors.length - 1].state.doc.length}});
      editors[editors.length - 1].focus();
    } else {
      editors[0].dispatch({selection: {anchor: 0}});
      editors[0].focus();
    }    



    return oldPos;
  }  

  ignoreEvent() {
    return true;
  }

  destroy(dom) {
    dom.EditorWidget.destroy();
  }
}

const matcher = (ref, view) => {
  return new BallancedMatchDecorator2({
    tag: 'TB',
    decoration: (match) => {
      
      return Decoration.replace({
        widget: new Widget(match, ref, view)
      });
    }
  });
};

const placeholder = ViewPlugin.fromClass(
  class {
    constructor(view) {
      this.disposable = [];
      this.placeholder = matcher(this.disposable, view).createDeco(view);
    }
    update(update) {
      //console.log('update Deco');
      //console.log(this.disposable );
      this.placeholder = matcher(this.disposable, update).updateDeco(
        update,
        this.placeholder
      );
    }
    destroy() {
      //console.log("removed holder");
      //console.log("disposable");
      //console.log(this.disposable);
      this.disposable.forEach((el) => {
        el.destroy();
      });
    }
  },
  {
    decorations: (instance) => instance.placeholder,
    provide: (plugin) =>
      EditorView.atomicRanges.of((view) => {
        var _a;
      
        return (
          ((_a = view.plugin(plugin)) === null || _a === void 0
            ? void 0
            : _a.placeholder) || Decoration.none
        );
      })
  }
);







