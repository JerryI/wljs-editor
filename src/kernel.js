import { EditorView, minimalSetup } from "codemirror";

import {language} from "@codemirror/language"


import {javascriptLanguage, javascript } from "@codemirror/lang-javascript"

import {markdownLanguage, markdown} from "@codemirror/lang-markdown"

import {htmlLanguage, html} from "@codemirror/lang-html"

import {indentWithTab} from "@codemirror/commands" 
 
import { MatchDecorator, WidgetType, keymap } from "@codemirror/view"

import rainbowBrackets from 'rainbowbrackets'

/*import { phraseEmphasis } from './../JSLibs/markword/phraseEmphasis';
import { heading, headingRE } from './../JSLibs/markword/heading';
import { wordmarkTheme } from './../JSLibs/markword/wordmarkTheme';
import { link } from './../JSLibs/markword/link';
import { listTask } from './../JSLibs/markword/listTask';
import { image } from './../JSLibs/markword/image';
import { blockquote } from './../JSLibs/markword/blockquote';
import { codeblock } from './../JSLibs/markword/codeblock';
import { webkitPlugins } from './../JSLibs/markword/webkit';

import { frontMatter } from './../JSLibs/markword/frontMatter';*/
import { Balanced } from "node-balanced";
import { Mma } from "mma-uncompress/src/mma";

import {
  highlightSpecialChars, drawSelection, highlightActiveLine, dropCursor,
  rectangularSelection, crosshairCursor, placeholder,
  highlightActiveLineGutter
} from "@codemirror/view"

import { EditorState, Compartment } from "@codemirror/state"
import { syntaxHighlighting, indentOnInput, bracketMatching, defaultHighlightStyle } from "@codemirror/language"
import { history, historyKeymap } from "@codemirror/commands"
import { highlightSelectionMatches } from "@codemirror/search"
import { autocompletion, closeBrackets } from "@codemirror/autocomplete"

import {
  Decoration,
  ViewPlugin
} from "@codemirror/view"

import {StreamLanguage} from "@codemirror/language"
import {spreadsheet} from "@codemirror/legacy-modes/mode/spreadsheet"

import { wolframLanguage } from "priceless-mathematica/src/mathematica/mathematica"
import { defaultFunctions } from "priceless-mathematica/src/mathematica/functions"

import { Arrowholder, Greekholder } from "priceless-mathematica/src/sugar/misc"
import { fractionsWidget } from "priceless-mathematica/src/sugar/fractions";
import { subscriptWidget } from "priceless-mathematica/src/sugar/subscript";
import { supscriptWidget } from "priceless-mathematica/src/sugar/supscript";
import { squareRootWidget } from "priceless-mathematica/src/sugar/squareroot";
import { matrixWidget } from "priceless-mathematica/src/sugar/matrix";
import { cellTypesHighlight } from "priceless-mathematica/src/sugar/cells"

import { BallancedMatchDecorator } from "priceless-mathematica/src/sugar/matcher";

const languageConf = new Compartment

const extras = []


let globalExtensions = []

window.EditorAutocomplete = defaultFunctions;
window.EditorAutocomplete.extend = (list) => {
  window.EditorAutocomplete.push(...list);
  wolframLanguage.reBuild(window.EditorAutocomplete);
}

console.log('loaded!');

const validator = new Balanced({
  open: ['{', '[', '('],
  close: ['}', ']', ')'],
  balance: true
});

const unknownLanguage = StreamLanguage.define(spreadsheet);
const regLang = new RegExp(/^[\w]*\.[\w]+/);

function checkDocType(str) {
  const r = regLang.exec(str);

  const arr = Object.values(window.SupportedLanguages);

  for (let i=0; i<arr.length; ++i) {
    //console.log(arr[i]);
    //console.log(arr[i].check(r));
    if (arr[i].check(r)) return arr[i];
  }



  /*switch(r[1]) {
    case 'js': 
      return {type: javascriptLanguage.name, lang: javascript()}; 
    case 'md':
      return {type: markdownLanguage.name, lang: markdownPlugins};
    case 'html':
    case 'htm':
    case 'wsp':
      return {type: htmlLanguage.name, lang: html()};
  }*/

  return {plugins: unknownLanguage, name: 'spreadsheet', legacy: true};
}

const autoLanguage = EditorState.transactionExtender.of(tr => {
  if (!tr.docChanged) return null
  let docType = checkDocType(tr.newDoc.line(1).text);

  if (docType.legacy) {
    //hard to distinguish...


    if (tr.startState.facet(language).name == docType.name) return null;
    console.log('switching... to '+docType.name);
    return {
      effects: languageConf.reconfigure(docType.plugins)
    }

  } else {
    //if it is the same

    if (docType.name === tr.startState.facet(language).name) return null;

    console.log('switching... to '+docType.name);
    return {
      effects: languageConf.reconfigure(docType.plugins)
    }
  }
})

/*const markdownPlugins = [
  markdown(),
  /*wordmarkTheme(),
  markdown(),
  listTask(),
  phraseEmphasis(),
  heading(),
  link(),
  image(),
  blockquote(),
  codeblock(),
  frontMatter()
]*/

const BoxesMatcher = (ref, view) => { return new BallancedMatchDecorator({
  regexp: /FrontEndBox\[/,
  decoration: match => Decoration.replace({
    widget: new BoxesWidget(match, ref, view),
  })
}) };

const BoxesHolder = ViewPlugin.fromClass(class {
  constructor(view) {
    this.disposable = [];
    this.BoxesHolder = BoxesMatcher(this.disposable, view).createDeco(view);
    
  }
  update(update) {
    this.BoxesHolder = BoxesMatcher(this.disposable, update).updateDeco(update, this.BoxesHolder);
  }
  destroy() {
    console.log('removed holder');
    console.log('disposable');
    console.log(this.disposable);
    this.disposable.forEach((el)=>{
        el.dispose();
    });
  }
}, {
  decorations: instance => instance.BoxesHolder,
  provide: plugin => EditorView.atomicRanges.of(view => {
    var _a;
    return ((_a = view.plugin(plugin)) === null || _a === void 0 ? void 0 : _a.BoxesHolder) || Decoration.none;
  })
});   

class BoxesWidget extends WidgetType {
  constructor(visibleValue, ref, view) {
    super();
    this.view = view;
    this.visibleValue = visibleValue;
    this.ref = ref;
    this.subEditor = compactWLEditor;
  }
  eq(other) {
    return this.visibleValue.str === other.visibleValue.str;
  }
  updateDOM(dom, view) {
    console.log('update widget DOM');
    return true
  }
  toDOM(view) {
    let span = document.createElement("span");
    span.classList.add("subscript-tail");
 
    const args = this.visibleValue.args;
    const visibleValue = this.visibleValue;
    
    const recreateString = (args) => {
      this.visibleValue.str =  'FrontEndBox['+args[0]+','+args[1]+']';
      console.log('recreated');
      console.log(this.visibleValue.str);
      const changes = {from: visibleValue.pos, to: visibleValue.pos + visibleValue.length, insert: this.visibleValue.str};
      this.visibleValue.length = this.visibleValue.str.length;

      return changes;
    }

    this.subEditor({
      doc: args[0],
      parent: span,
      update: (upd) => {
        const valid = validator.matchContentsInBetweenBrackets(upd, []);
        if (!valid) return;

        this.visibleValue.args[0] = upd;
        const change = recreateString(this.visibleValue.args);
        console.log('insert change');
        console.log(change);
        view.dispatch({changes: change});
      },
      eval: () => {
        view.viewState.state.config.eval();
      }
    });

    console.log("args:");
    console.log(args);
    const decoded = Mma.DecompressDecode(args[1]);
    const json = Mma.toArray(decoded.parts[0]);

    const cuid = Date.now() + Math.floor(Math.random() * 100);
    var global = {call: cuid};
    let env = {global: global, element: span}; //Created in CM6
    interpretate(json, env);


    return span;
  }

  ignoreEvent() {
    return true;
  }

  destroy() {
    console.error('not implemented');
  }
}

const ExecutableMatcher = (ref) => { return new MatchDecorator({
  regexp: /FrontEndExecutable\["([^"]+)"\]/g,
  decoration: match => Decoration.replace({
    widget: new ExecutableWidget(match[1], ref),
  })
}) };

const ExecutableHolder = ViewPlugin.fromClass(class {
  constructor(view) {
    this.disposable = [];
    this.ExecutableHolder = ExecutableMatcher(this.disposable).createDeco(view);
    
  }
  update(update) {
    this.ExecutableHolder = ExecutableMatcher(this.disposable).updateDeco(update, this.ExecutableHolder);
  }
  destroy() {
    console.log('removed holder');
    console.log('disposable');
    console.log(this.disposable);
    this.disposable.forEach((el)=>{
        el.dispose();
    });
  }
}, {
  decorations: instance => instance.ExecutableHolder,
  provide: plugin => EditorView.atomicRanges.of(view => {
    var _a;
    return ((_a = view.plugin(plugin)) === null || _a === void 0 ? void 0 : _a.ExecutableHolder) || Decoration.none;
  })
});   

class ExecutableWidget extends WidgetType {
  constructor(name, ref) {
    super();
    this.ref = ref;
    this.name = name;
  }
  eq(other) {
    return this.name === other.name;
  }
  toDOM() {
    let elt = document.createElement("div");
    elt.classList.add("frontend-object");
    elt.setAttribute('data-object', this.name);
    
    //callid
    const cuid = Date.now() + Math.floor(Math.random() * 100);
    var global = {call: cuid};
    this.global = global; //pass a ref to the global memeory

    let env = {global: global, element: elt}; //Created in CM6
    console.log("CM6: creating an object with key "+this.name);
    this.fobj = new ExecutableObject(this.name, env);
    this.fobj.execute()     

    this.ref.push(this.fobj);

    return elt;
  }
  ignoreEvent() {
    return true; 
  }
  destroy() {
    console.log('widget got destroyed! removing objects');
    Object.values(this.global.stack).forEach((o)=>{
      console.log('removing instance: '+o.uid+' ...');
      o.dispose();
    });
    console.log('finished. now get rid of the editor itself. Bye!');
  }
}

const ExecutableInlineMatcher = (ref) => { return new MatchDecorator({
  regexp: /FrontEndInlineExecutable\["([^"]+)"\]/g,
  decoration: match => Decoration.replace({
    widget: new ExecutableInlineWidget(match[1], ref),
  })
}) };

const ExecutableInlineHolder = ViewPlugin.fromClass(class {
  constructor(view) {
    this.disposable = [];
    this.ExecutableInlineHolder = ExecutableInlineMatcher(this.disposable).createDeco(view);
    
  }
  update(update) {
    this.ExecutableInlineHolder = ExecutableInlineMatcher(this.disposable).updateDeco(update, this.ExecutableInlineHolder);
  }
  destroy() {
    console.log('removed holder');
    console.log('disposable');
    console.log(this.disposable);
    this.disposable.forEach((el)=>{
        el.dispose();
    });
  }
}, {
  decorations: instance => instance.ExecutableInlineHolder,
  provide: plugin => EditorView.atomicRanges.of(view => {
    var _a;
    return ((_a = view.plugin(plugin)) === null || _a === void 0 ? void 0 : _a.ExecutableInlineHolder) || Decoration.none;
  })
});   

function stringToHash(string) {
             
  let hash = 0;
   
  if (string.length == 0) return hash;
   
  for (let i = 0; i < string.length; i++) {
      let char = string.charCodeAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash;
  }
   
  return hash;
}

class ExecutableInlineWidget extends WidgetType {
  constructor(name, ref) {
    super();
    this.ref = ref;
    this.name = name;
  }
  eq(other) {
    return this.name === other.name;
  }
  toDOM() {
    let elt = document.createElement("div");
    elt.classList.add("frontend-object");
    elt.setAttribute('data-object', 'inline');
    
    //callid
    const cuid = Date.now() + Math.floor(Math.random() * 100);
    var global = {call: cuid};
    this.global = global; //pass a ref to the global memeory

    let env = {global: global, element: elt}; //Created in CM6
    console.log("CM6: creating an inline object");

    const decoded = Mma.DecompressDecode(this.name);
    const json = Mma.toArray(decoded.parts[0]);
    //TODO

    const hash = stringToHash(this.name);
    if (!(hash in ObjectHashMap)) {
      const o = new ObjectStorage(hash);
      o.cached = true;
      o.cache = json;
    }

    this.fobj = new ExecutableObject(hash, env);
    this.fobj.execute();     

    this.ref.push(this.fobj);

    return elt;
  }

  ignoreEvent() {
    return true; 
  }
  destroy() {
    console.log('widget got destroyed! removing objects');
    Object.values(this.global.stack).forEach((o)=>{
      console.log('removing instance: '+o.uid+' ...');
      o.dispose();
    });
    console.log('finished. now get rid of the editor itself. Bye!');
  }
}

let compactWLEditor = null;

compactWLEditor = (args) => {
  let editor = new EditorView({
  doc: args.doc,
  extensions: [
    keymap.of([
      { key: "Enter", preventDefault: true, run: function (editor, key) { 
        return true;
      } }
    ]),  
    keymap.of([
      { key: "Shift-Enter", preventDefault: true, run: function (editor, key) { 
        args.eval();
        return true;
      } }
    ]),    
    args.extensions || [],   
    minimalSetup,
    editorCustomThemeCompact,      
    wolframLanguage.of(window.EditorAutocomplete),
    ExecutableHolder,
    ExecutableInlineHolder,
    fractionsWidget(compactWLEditor),
    subscriptWidget(compactWLEditor),
    supscriptWidget(compactWLEditor),
    matrixWidget(compactWLEditor),
    squareRootWidget(compactWLEditor),
    bracketMatching(),
    rainbowBrackets(),
    BoxesHolder,
    Greekholder,
    Arrowholder,
    extras,
    
    EditorView.updateListener.of((v) => {
      if (v.docChanged) {
        args.update(v.state.doc.toString());
      }
    })
  ],
  parent: args.parent
  });

  editor.viewState.state.config.eval = args.eval;
  return editor;
}


const mathematicaPlugins = [
  wolframLanguage.of(window.EditorAutocomplete), 
  ExecutableHolder, 
  ExecutableInlineHolder,
  fractionsWidget(compactWLEditor),
  subscriptWidget(compactWLEditor),
  supscriptWidget(compactWLEditor),
  matrixWidget(compactWLEditor),
  squareRootWidget(compactWLEditor),
  bracketMatching(),
  rainbowBrackets(),
  Greekholder,
  Arrowholder,
  BoxesHolder,
  extras
]



import { defaultKeymap } from "@codemirror/commands";

let editorCustomTheme = EditorView.theme({
  "&.cm-focused": {
    outline: "1px dashed #696969", 
    background: 'inherit'
  },
  ".cm-line": {
    padding: 0,
    'padding-left': '2px',
    'align-items': 'center'
  },
  ".cm-activeLine": {
    'background-color': 'transparent'
  }
});

let editorCustomThemeCompact = EditorView.theme({
  "&.cm-focused": {
    outline: "1px dashed #696969",
    background: 'inherit'
  },
  ".cm-line": {
    padding: 0,
    'padding-left': '2px',
    'align-items': 'center'
  },
  ".cm-activeLine": {
    'background-color': 'transparent'
  },
  ".cm-scroller": {
    'line-height': 'inherit',
    'overflow-x': 'overlay',
    'overflow-y': 'overlay',
    'align-items': 'initial'
  },
  ".cm-content": {
    "padding": '0px 0'
  }
});

let globalCMFocus = false;

class CodeMirrorCell {
    origin = {}
    editor = {}
    trash = []

    forceFocusNext() {
      globalCMFocus = true;
    }
  
    addDisposable(el) {
      this.trash.push(el);
    }
    
    dispose() {
      this.editor.destroy();
    }
    
    constructor(parent, data) {
      this.origin = parent;
      const origin = this.origin;
      
      const initialLang = checkDocType(data).plugins;

      const editor = new EditorView({
        doc: data,
        extensions: [
          highlightSpecialChars(),
          history(),
          drawSelection(),
          dropCursor(),
          indentOnInput(),
          bracketMatching(),
          closeBrackets(),
          EditorView.lineWrapping,
          autocompletion(),
          syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
          highlightSelectionMatches(),
          cellTypesHighlight,
          window.Extensions,
          placeholder('Type Wolfram Expression / .md / .html / .js'),
          
          languageConf.of(initialLang),
          autoLanguage, 
          
          keymap.of([indentWithTab,
            { key: "Backspace", run: function (editor, key) { 
              if(editor.state.doc.length === 0) { origin.remove() }  
            } },
            { key: "ArrowLeft", run: function (editor, key) {  
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } },   
            { key: "ArrowRight", run: function (editor, key) {  
              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } },                      
            { key: "ArrowUp", run: function (editor, key) {  
              console.log('arrowup');
              console.log(editor.state.selection.ranges[0]);
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                origin.focusPrev(origin);

              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } },
            { key: "ArrowDown", run: function (editor, key) { 
              console.log('arrowdown');
              console.log(editor.state.selection.ranges[0]);
              if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
                origin.focusNext(origin);

              editor.editorLastCursor = editor.state.selection.ranges[0].to;  
            } },
            { key: "Shift-Enter", preventDefault: true, run: function (editor, key) { 
              console.log(editor.state.doc.toString()); 
              origin.eval(editor.state.doc.toString()) 
            } }
            , ...defaultKeymap, ...historyKeymap
          ]),
          globalExtensions,
          
          EditorView.updateListener.of((v) => {
            if (v.docChanged) {
              origin.save(v.state.doc.toString().replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"'));
            }
          }),
            editorCustomTheme
        ],
        parent: this.origin.element
      });
      
      this.editor = editor;
      this.editor.viewState.state.config.eval = () => {
        origin.eval(this.editor.state.doc.toString());
      };
  
      if(globalCMFocus) editor.focus();
      globalCMFocus = false;    
      
      return this;
    }
  }

  //for dynamics
  core.EditorView = async (args, env) => {
    //cm6 inline editor (editable or read-only)
    const textData = await interpretate(args[0], env);
    const options = core._getRules(args, env);

    let updateFunction = () => {};

    if (options.Event) {
      //then it means this is like a slider

    } else {
      //then it is an output thing
    }

    compactWLEditor({doc: textData, parent: env.element, update: updateFunction});
  }

  core.EditorView.update = async (args, env) => {
    const textData = await interpretate(args[0], env);
    env.local.dispatch(textData);
  }

  core.PreviewCell = (element, data) => {
      const initialLang = checkDocType(data).plugins;

      const editor = new EditorView({
        doc: data,
        extensions: [
          highlightSpecialChars(),
          bracketMatching(),
          closeBrackets(),
          EditorView.lineWrapping,
          syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
          highlightSelectionMatches(),
          cellTypesHighlight,
          languageConf.of(initialLang),
          autoLanguage, 
          globalExtensions,
          editorCustomTheme,
          EditorState.readOnly.of(true)
        ],
        parent: element
      });
      

  }
  
  window.SupportedLanguages.push({
    check: (r) => {return(r === null)},
    legacy: true, 
    plugins: mathematicaPlugins,
    name: 'mathematica'
  });

  window.SupportedCells['codemirror'] = {
    view: CodeMirrorCell
  };

  window.javascriptLanguage = javascriptLanguage
  window.javascript = javascript
  window.markdownLanguage = markdownLanguage
  window.markdown = markdown
  window.htmlLanguage = htmlLanguage
  window.html = html

  window.EditorView = EditorView
  window.highlightSpecialChars = highlightSpecialChars
  window.EditorState = EditorState
  window.syntaxHighlighting = syntaxHighlighting
  window.defaultHighlightStyle = defaultHighlightStyle
  window.editorCustomTheme = editorCustomTheme

  if (window.OfflineMode)
    extras.push(window.EditorState.readOnly.of(true))
