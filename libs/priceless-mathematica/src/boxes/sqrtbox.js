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
  
  export function SqrtBoxWidget(viewEditor) {
    compactCMEditor = viewEditor;
    return [
      //mathematicaMathDecoration,
      placeholder,
      keymap.of([{ key: "Ctrl-2", run: snippet() }])
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
            changes: { from, to, insert: "(*SqrtBox[*)Sqrt[_](*]SqrtBox*)" },
            range: EditorSelection.cursor(from)
          };
        }
        return {
          changes: { from, to, insert: "(*SqrtBox[*)Sqrt["+prev+"](*]SqrtBox*)" },
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

    constructor(visibleValue, view, dom, sliceRanges) {
      this.view = view;
      this.visibleValue = visibleValue;
      const self = this;

      console.log('creating InstanceWidget');

      this.editor = compactCMEditor({
        //slice SqrtBox[...]
        doc: visibleValue.args[0].body.slice(...sliceRanges),
        parent: dom,
        update: (upd) => self.applyChanges(upd),
        eval: () => {
          view.viewState.state.config.eval();
        },
        extensions: [
          keymap.of([
            { key: "ArrowRight", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                view.focus()
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } },   
            { key: "ArrowLeft", run: function (editor, key) {  
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                view.focus()
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } }
          ])
        ]       
      });
    }

    applyChanges(update) {

      const args = this.visibleValue.args;
      const data = "Sqrt[" + update + "]";

      //const old = this.visibleValue.str;
      
      //console.log(this.visibleValue.pos);
      const changes = {...args[0], insert: data};
      //console.log(args);
      //const changes = {from: this.visibleValue.argsPos + args[0], to: this.visibleValue.argsPos + args[0].from + args[0].body.length - 1, insert: data};
      //console.warn('changes will be applied to...');
      //console.log(this.view.viewState.state.doc.toString().slice(changes.from, changes.to));
      
      //this.visibleValue.args[0] = data;
      //this.visibleValue.str = data;
      //this.visibleValue.length = this.visibleValue.str.length;

      //console.log('insert change');
      //console.log(changes);
      this.view.dispatch({changes: changes});
    }


    update(visibleValue) {
      //console.log('Update instance: new ranges & arguments');
      this.visibleValue.pos = visibleValue.pos;
      this.visibleValue.argsPos = visibleValue.argsPos;
      this.visibleValue.args = visibleValue.args;
    }

    destroy() {
      console.warn('destroy Instance of Widget!');
      this.editor.destroy();
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
      //console.log('update widget DOM');
      dom.EditorInstance.update(this.visibleValue);

      return true
    }

    toDOM(view) {
      console.log('Create a new one!');

      let span = document.createElement("span");
      span.classList.add("sqroot");

      //console.log('Visible value:');
      //console.log(this.visibleValue);

      const self = this;
  
      const head = document.createElement("span");
      head.classList.add("radicand");
      
      span.EditorInstance = new EditorInstance(this.visibleValue, view, head, [5,-1]);

      span.appendChild(head);

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
        tag: 'SqrtBox',
        separator: /\(\*,\*\)/gm
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
  