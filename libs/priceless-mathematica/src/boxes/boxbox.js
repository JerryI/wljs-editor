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
  
  class EditorInstance {
  
    constructor(visibleValue, view, span) {
      this.view = view;
      this.visibleValue = visibleValue;
  
      this.args = matchArguments(visibleValue.str, /\(\*,\*\)/gm);
  
      const self = this;
      //console.log(visibleValue);

    

      const string = this.args[1].body.slice(3,-3);
      //console.log(string);
      const decoded = Mma.DecompressDecode(string);
      const json = Mma.toArray(decoded.parts[0]);

      this.data = json;
  
      const cuid = uuidv4();
      let global = {call: cuid, element: span, origin: self};
      let env = {global: global, element: span}; //Created in CM6
      interpretate(json, env).then(() => {
        self.editor = compactCMEditor({
          doc: self.args[0].body.slice(1,-1),
          parent: env.global.element,
          update: (upd) => this.applyChanges(upd),
          eval: () => {
            view.viewState.state.config.eval();
          },
          extensions: [
            keymap.of([
              { key: "ArrowLeft", run: function (editor, key) {  
                if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                  view.focus()
                editor.editorLastCursor = editor.state.selection.ranges[0].to;  
              } }, 
              { key: "ArrowRight", run: function (editor, key) {  
                if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                  view.focus()
                editor.editorLastCursor = editor.state.selection.ranges[0].to;  
              } }
            ])
          ]
        });  
      });

    }

    applyChanges(update, pos) {
        const args = this.args;
        const relative = this.visibleValue.argsPos;
    
        const data = '('+update+')';
        const changes = {from: relative + args[0].from, to: relative + args[0].from + args[0].length, insert: data};
  
    
        args[0].length = data.length;
  
  
        this.view.dispatch({changes: changes});
      }    
  
    update(visibleValue) {
      //console.log('Update instance: new ranges & arguments');
      this.visibleValue.pos = visibleValue.pos;
      this.visibleValue.argsPos = visibleValue.argsPos;
    }
  
    destroy() {
      console.warn('destroy Instance of Widget is not implemented');
      this.editor.destroy();
      delete this.data;
    }
  }
  
  class Widget extends WidgetType {
    constructor(visibleValue, ref, view) {
      super();
      this.view = view;
      this.visibleValue = visibleValue;
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
      dom.EditorInstance.update(this.visibleValue);
  
      return true
    }
  
    toDOM(view) {
      console.log('Create a new one!');
  
      let span = document.createElement("span");
      span.classList.add("subscript-tail");
  
      span.EditorInstance = new EditorInstance(this.visibleValue, view, span);
  
  
      return span;
    }
  
    ignoreEvent() {
      return true;
    }
  
    destroy(dom) {
      dom.EditorInstance.destroy();
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
        console.log("removed holder");
        console.log("disposable");
        console.log(this.disposable);
        this.disposable.forEach((el) => {
          el.dispose();
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
  






