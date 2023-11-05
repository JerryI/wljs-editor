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

  export function ViewBoxWidget(viewEditor) {
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
      //console.log(this.args);

      const string = this.args[1].body.slice(3,-3);
      //console.log(string);
      const decoded = Mma.DecompressDecode(string);
      const json = Mma.toArray(decoded.parts[0]);

      this.data = json;
  
      const cuid = uuidv4();
      let global = {call: cuid};
      let env = {global: global, element: span}; //Created in CM6
      interpretate(json, env);
   
    }
  
  
    update(visibleValue) {
      //console.log('Update instance: new ranges & arguments');
      this.visibleValue.pos = visibleValue.pos;
      this.visibleValue.argsPos = visibleValue.argsPos;
    }
  
    destroy() {
      console.warn('destroy Instance of Widget is not implemented');
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
      span.classList.add("frontend-view");
  
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
      tag: 'VB',
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
  






