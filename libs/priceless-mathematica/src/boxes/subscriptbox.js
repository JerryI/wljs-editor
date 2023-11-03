import {
  EditorView,
  Decoration,
  ViewPlugin,
  WidgetType,
  MatchDecorator
} from "@codemirror/view";
import { isCursorInside } from "./utils";

import { BallancedMatchDecorator2 } from "./matcher";

import { keymap } from "@codemirror/view";
 
import { EditorSelection } from "@codemirror/state";

import { Balanced } from "node-balanced";

var compactCMEditor; 

export function SubscriptBoxWidget(viewEditor) {
  compactCMEditor = viewEditor;
  return [
    //mathematicaMathDecoration,
    placeholder,
    keymap.of([{ key: "Ctrl--", run: snippet() }])
  ];
}

function snippet() {
  return ({ state, dispatch }) => {
    if (state.readOnly) return false;
    let changes = state.changeByRange((range) => {
      let { from, to } = range;
      //if (atEof) from = to = (to <= line.to ? line : state.doc.lineAt(to)).to
      const prev = state.sliceDoc(from, to);
      if (prev.length === 0) {
        return {
          changes: { from, to, insert: "(*SubscriptBox[*)Subscript[_(*|*),(*|*)_](*]SubscriptBox*)" },
          range: EditorSelection.cursor(from)
        };
      }
      return {
        changes: { from, to, insert: "(*SubscriptBox[*)Subscript["+ prev +"(*|*),(*|*)_](*]SubscriptBox*)" },
        range: EditorSelection.cursor(from)
      };
    });

    dispatch(
      state.update(changes, { scrollIntoView: true, userEvent: "input" })
    );
    return true;
  };
}

class EditorInstance {

  constructor(visibleValue, view, head, sub) {
    this.view = view;
    this.visibleValue = visibleValue;
    const self = this;

    //console.log(visibleValue);

    console.log('creating InstanceWidget');

    let topEditor, bottomEditor;

    console.log(self.visibleValue);

    topEditor = compactCMEditor({
      doc: self.visibleValue.args[0].body.slice(10),
      parent: head,
      update: (upd) => this.applyChanges(upd, 0),
      extensions: [
        keymap.of([
          { key: "ArrowLeft", run: function (editor, key) {  
            if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
              view.focus()
            editor.editorLastCursor = editor.state.selection.ranges[0].to;  
          } },   
          { key: "ArrowRight", run: function (editor, key) {  
            if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
              bottomEditor.focus();
            editor.editorLastCursor = editor.state.selection.ranges[0].to;  
          } }
        ])
      ]
    });

    bottomEditor = compactCMEditor({
      doc: self.visibleValue.args[2].body.slice(0, -1),
      parent: sub,
      update: (upd) => this.applyChanges(upd, 2),
      extensions: [
        keymap.of([
          { key: "ArrowRight", run: function (editor, key) {  
            if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
              view.focus()
            editor.editorLastCursor = editor.state.selection.ranges[0].to;  
          } },   
          { key: "ArrowLeft", run: function (editor, key) {  
            if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
              topEditor.focus();
            editor.editorLastCursor = editor.state.selection.ranges[0].to;  
          } }
        ])
      ]            
    });

    //if (focusNext) bottomEditor.focus();
    //focusNext = false;    
    
    this.topEditor = topEditor;
    this.bottomEditor = bottomEditor;

    
  }

  applyChanges(update, pos) {
    const args = this.visibleValue.args;

    if (pos == 0) {
      //uppder one
      const changes = {...args[pos], insert: 'Subscript['+update};
      this.view.dispatch({changes: changes});
    } else {
      const changes = {...args[pos], insert: update+']'};
      this.view.dispatch({changes: changes});
      //lower one
    }
  }


  update(visibleValue) {
    //console.log('Update instance: new ranges & arguments');
    this.visibleValue.pos = visibleValue.pos;
    this.visibleValue.argsPos = visibleValue.argsPos;
    this.visibleValue.args = visibleValue.args;
  }

  destroy() {
    console.warn('destroy Instance of Widget!');
    this.topEditor.destroy();
    this.bottomEditor.destroy();
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

    const span = document.createElement("span");
    const head = document.createElement("span");
    head.classList.add("subscript-tail");
    
    const sub = document.createElement("sub");
    sub.classList.add("subscript-tail");

    span.appendChild(head);
    span.appendChild(sub);

    span.EditorInstance = new EditorInstance(this.visibleValue, view, head, sub);


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
    tag: {
      tag: 'SubscriptBox',
      separator: /\(\*\|\*\)/gm
    },
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
