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

export function BoxBoxWidget(viewEditor) {
  compactCMEditor = viewEditor;
  return [
    //mathematicaMathDecoration,
    placeholder
  ];
}

class EditorWidget {

  constructor(visibleValue, view, span, ref) {
    return this._construct(visibleValue, view, span, ref);
  }

  _construct(visibleValue, view, span, ref) {
    this.view = view;
    this.span = span;
    this.visibleValue = visibleValue;

    this.args = matchArguments(visibleValue.str, /\(\*,\*\)/gm);

    const self = this;
    //ref.push(self);
    //console.log(visibleValue);

    
    this.epilog = {
        offset: 0,
        string: ''
      };

    this.prolog = {
        offset: 0,
        string: ''          
    };
  

    const string = this.args[1].body.slice(3,-3);
    //console.log(string);
    const decoded = Mma.DecompressDecode(string);
    const json = Mma.toArray(decoded.parts[0]);

    this.data = json;

    const cuid = uuidv4();
    let global = {call: cuid, element: span, origin: self};
    let env = {global: global, element: span}; //Created in CM6
    this.env = env;

    interpretate(json, env).then(() => {
      if (env.options?.Head) {
        self.prolog.offset = env.options.Head.length + 1;
        self.prolog.string = env.options.Head + "["
        self.epilog.offset = 1;
        self.epilog.string = "]"
      }

      if (env.options?.Event) {
        console.warn('Event listeners are enabled!');
        self.events = env.options.Event;
      }

      if (env.options?.String) {
        //just make a DOM element, if this is a string
        self.prolog.offset = 1;
        self.prolog.string = '"'
        self.epilog.offset = 1;
        self.epilog.string = '"';

        if (env.options?.HeadString) {
          self.prolog.string = env.options.HeadString;
          self.prolog.offset = self.prolog.string.length;
        }

        if (env.options?.TailString) {
          self.epilog.string = env.options.TailString;
          self.epilog.offset = self.epilog.string.length;
        }        

        self.editor = {
          destroy: () => {
            console.log('Nothing to destroy, this is just a text field.');
          }
        };
        const aa = document.createElement('span');
        this.aa;
        aa.onkeydown = function(e) {
          // User hits enter key and is not holding shift
          if (e.keyCode === 13) {
               e.preventDefault()
           }
       };
        aa.contentEditable = "plaintext-only";
        aa.innerText = self.args[0].body.slice(1 + self.prolog.offset, -1 - self.epilog.offset);
        aa.addEventListener('input', console.log);
        aa.addEventListener("input", () => {
          console.log('Update');
          console.log(aa.innerText);
          this.applyChanges(aa.innerText);
        });  
        
        env.global.element.appendChild(aa);

        if(self.events) server.kernel.emitt(self.events, 'Null', 'Mounted');

        return;
      }

      

      self.editor = compactCMEditor({
        doc: self.args[0].body.slice(1 + self.prolog.offset, -1 - self.epilog.offset),
        parent: env.global.element,
        update: (upd) => this.applyChanges(upd),
        eval: () => {
          view.viewState.state.config.eval();
        },
        extensions: [
          keymap.of([
            { key: "ArrowLeft", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to) {

                console.log(self.visibleValue.pos);
                //if (self.visibleValue.pos == 0) return;
  
                view.dispatch({selection: {anchor: self.visibleValue.pos}});
                view.focus();

                editor.editorLastCursor = undefined;
                return;
              }
                
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } }, 
            { key: "ArrowRight", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to) {
                console.log(self.visibleValue.pos);
                //if (self.visibleValue.pos == 0) return;
  
                view.dispatch({selection: {anchor: self.visibleValue.pos + self.visibleValue.length}});
                view.focus();
                editor.editorLastCursor = undefined;
                return;
              }
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } }
          ])
        ]
      });

      if(self.events) server.kernel.emitt(self.events, 'Null', 'Mounted');  

    });

  }

  applyChanges(update, pos) {
      const args = this.args;
      const relative = this.visibleValue.argsPos;
  
      const data = '('+this.prolog.string+update+this.epilog.string+')';
      const changes = {from: relative + args[0].from, to: relative + args[0].from + args[0].length, insert: data};

      //update imprint
      this.visibleValue.str = this.visibleValue.str.substring(0, args[0].from).concat(data, this.visibleValue.str.substring(args[0].from + args[0].length));

      const delta = data.length - args[0].length
      args[0].length = data.length;
      this.visibleValue.length = this.visibleValue.length + delta;

      this.view.dispatch({changes: changes});
  }    

  update(visibleValue) {
    //console.log('Update instance: new ranges & arguments');

    if (this.visibleValue.str != visibleValue.str) {
      console.warn('Out of sync');
      console.log('recreating InstanceWidget');

      this.destroy();

      //HARD RESET
      this.span.replaceChildren();

      this._construct(visibleValue, this.view, this.span);


      return;
    }

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
    this.editor.destroy();

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
    console.log('update widget DOM');
    this.DOMElement = dom;
    dom.EditorWidget.update(this.visibleValue);

    return true
  }

  toDOM(view) {
    console.log('Create a new one!');

    let span = document.createElement("span");
    span.classList.add("subscript-tail");

    span.EditorWidget = new EditorWidget(this.visibleValue, view, span, []);

    const self = this;
    
    this.reference.push({destroy: () => {
      self.destroy(span);
    }});      

    this.DOMElement = span;

    return span;
  }

  skipPosition(pos, oldPos, selected) {
    if (oldPos.from != oldPos.to || selected) return pos;
    //this.DOMElement.EditorWidget.wantedPosition = pos;
    if (pos.from - oldPos.from > 0) {
      //this.DOMElement.EditorWidget.topEditor.dispatch()
      this.DOMElement.EditorWidget.editor.dispatch({selection: {anchor: 0}});
      this.DOMElement.EditorWidget.editor.focus();
      //this.DOMElement.EditorWidget.topEditor.focus();
    } else {
      const editor = this.DOMElement.EditorWidget.editor;
      editor.dispatch({selection: {anchor: editor.state.doc.length}});
      editor.focus();
      //this.DOMElement.EditorWidget.bottomEditor.focus();
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
    tag: 'BB',
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







