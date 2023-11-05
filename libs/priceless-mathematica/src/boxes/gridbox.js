import {
    EditorView,
    Decoration,
    ViewPlugin,
    WidgetType,
    MatchDecorator
  } from "@codemirror/view";
  import { isCursorInside } from "./utils";
  
  import { BallancedMatchDecorator2, matchArguments  } from "./matcher";
  
  import { keymap } from "@codemirror/view";
   
  import { EditorSelection } from "@codemirror/state";
  
  import { Balanced } from "node-balanced";
  
  var compactCMEditor; 
  
  export function GridBoxWidget(viewEditor) {
    compactCMEditor = viewEditor;
    return [
      //mathematicaMathDecoration,
      placeholder,
      //keymap.of([{ key: "Ctrl-m", run: snippet() }])
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
            changes: { from, to, insert: "(*GridBox[*)Subscript[_(*|*),(*|*)_](*]SubscriptBox*)" },
            range: EditorSelection.cursor(from)
          };
        }
        return {
          changes: { from, to, insert: "(*GridBox[*)Subscript["+ prev +"(*|*),(*|*)_](*]SubscriptBox*)" },
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
  
    constructor(visibleValue, view, tbody) {
      this.view = view;
      this.visibleValue = visibleValue;
      const self = this;

      this.tbody = tbody;

      this.args = matchArguments(visibleValue.str, /\(\*\|\|\*\)/gm).map((arg, index)=>{
        if (index % 2 != 0) return arg;
        return {...arg, body: matchArguments(arg.body, /\(\*\|\*\)/gm)}
      });
  
      //console.log(this.args);
      //return;
      const args = this.args;
 
  
      console.log('creating InstanceWidget');
  
      for (let i = 0; i < this.args.length; i+=2) {
        const tr        = document.createElement("tr");
        const cols = this.args[i].body;
  
        for (let j = 0; j < cols.length; j+=2) {
          const td = document.createElement("td");
          let text = cols[j].body;

          if (j ==  0 && i ==  0) text = text.slice(2);
          if (j ==  0 && i !=  0) text = text.slice(1);

          if (j == cols.length-1 && i == this.args.length-1) text = text.slice(0,-2);
          if (j == cols.length-1 && i != this.args.length-1) text = text.slice(0,-1);

          cols[j].editor = compactCMEditor({
            doc: text,
            parent: td,
            update: (upd) => this.applyChanges(upd, i,j),
            extensions: [
              keymap.of([
                { key: "ArrowLeft", run: function (editor, key) {  
                  if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                    if (j - 2 >= 0)
                      cols[j-2].editor.focus();
                    else
                      view.focus();
  
                  editor.editorLastCursor = editor.state.selection.ranges[0].to;  
                } }, 
                { key: "ArrowRight", run: function (editor, key) {  
                  if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                    if (j + 2 < cols.length)
                      cols[j+2].editor.focus();
                    else
                      view.focus();
  
                  editor.editorLastCursor = editor.state.selection.ranges[0].to;  
                } },             
                { key: "ArrowUp", run: function (editor, key) {  
                  if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                    if (i - 2 >= 0)
                      args[i-2].body[j].editor.focus();
                    else
                      view.focus();
  
                  editor.editorLastCursor = editor.state.selection.ranges[0].to;  
                } },             
                { key: "ArrowDown", run: function (editor, key) {  
                  if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                    if (i + 2 < args.length)
                      args[i+2].body[j].editor.focus();
                    else
                      view.focus();
  
                  editor.editorLastCursor = editor.state.selection.ranges[0].to;  
                } }
              ])
            ] 
          });


          //remove unnecesary
          delete cols[j].body;
  
          tr.appendChild(td);
        }
        tbody.appendChild(tr);
      }   
      
      console.log(this.args);
  
      
    }
  
    applyChanges(update, i,j) {
      
      const args = this.args;
      const parent = this.args[i].body;

      const relative1 = this.visibleValue.argsPos;
      const relative2 = this.args[i].from;

      let text = update;

      if (j ==  0 && i ==  0) text = '{{'+text;
      if (j ==  0 && i !=  0) text = '{'+text;

      if (j == parent.length-1 && i == args.length-1) text = text+'}}';
      if (j == parent.length-1 && i != args.length-1) text = text+'}';      

      const oldLength = parent[j].length;
      const changes = {from: relative1 + relative2 + parent[j].from, to: relative1 + relative2 + parent[j].from + oldLength, insert: text};
   
      //shift the next in a row
      for (let jj=j+1; jj<parent.length; jj+=1) {
        parent[jj].from += (text.length - oldLength);
      }

      //shift the next in the col
      for (let ii=i+1; ii<args.length; ii+=1) {
        args[ii].from += (text.length - oldLength);
      }

      this.args[i].length += (text.length - oldLength);


      //apply 
      parent[j].length = text.length;


      console.log(changes);
      //console.log(this.args);
  
      this.view.dispatch({changes: changes});      
    }
  
  
    update(visibleValue) {
      //console.log('Update instance: new ranges & arguments');
      this.visibleValue.pos = visibleValue.pos;
      this.visibleValue.argsPos = visibleValue.argsPos;
      //this.visibleValue.args = visibleValue.args;
    }
  
    destroy() {
      console.warn('destroy Instance of Widget!');
      for (let i = 0; i < this.args.length; i+=2) {
        const cols = this.args[i].body;
  
        for (let j = 0; j < cols.length; j+=2) {
          cols[j].editor.destroy();
        }
      }
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
      span.classList.add('matrix');
  
      const table      = document.createElement("table");
      table.classList.add('container');
      span.appendChild(table);
      
      const tbody      = document.createElement("tbody");
      table.appendChild(tbody);
  
      span.EditorInstance = new EditorInstance(this.visibleValue, view, tbody);
  
  
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
      tag: 'GB',
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
  