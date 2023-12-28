import { EditorView, minimalSetup } from "codemirror";

import {language} from "@codemirror/language"


import {javascriptLanguage, javascript } from "@codemirror/lang-javascript"

import {markdownLanguage, markdown} from "@codemirror/lang-markdown"

import {htmlLanguage, html} from "@codemirror/lang-html"

import {cssLanguage, css} from "@codemirror/lang-css"

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

import {
  highlightSpecialChars, drawSelection, highlightActiveLine, dropCursor,
  rectangularSelection, crosshairCursor, placeholder,
  highlightActiveLineGutter, lineNumbers
} from "@codemirror/view"

import {tags} from "@lezer/highlight"

import { EditorState, Compartment } from "@codemirror/state"
import { syntaxHighlighting, indentOnInput, bracketMatching, HighlightStyle} from "@codemirror/language"
import { history, historyKeymap } from "@codemirror/commands"
import { highlightSelectionMatches } from "@codemirror/search"
import { autocompletion, closeBrackets } from "@codemirror/autocomplete"

import {
  Decoration,
  ViewPlugin
} from "@codemirror/view"

import {StreamLanguage} from "@codemirror/language"
import {spreadsheet} from "@codemirror/legacy-modes/mode/spreadsheet"

import { wolframLanguage } from "../libs/priceless-mathematica/src/mathematica/mathematica"
import { defaultFunctions } from "../libs/priceless-mathematica/src/mathematica/functions"

import { Arrowholder, Greekholder } from "../libs/priceless-mathematica/src/sugar/misc"

import {FractionBoxWidget} from "../libs/priceless-mathematica/src/boxes/fractionbox"
import {SqrtBoxWidget} from "../libs/priceless-mathematica/src/boxes/sqrtbox"
import {SubscriptBoxWidget} from "../libs/priceless-mathematica/src/boxes/subscriptbox"
import {SupscriptBoxWidget} from "../libs/priceless-mathematica/src/boxes/supscriptbox"
import {GridBoxWidget} from "../libs/priceless-mathematica/src/boxes/gridbox"

import {ViewBoxWidget} from "../libs/priceless-mathematica/src/boxes/viewbox"
import {BoxBoxWidget} from "../libs/priceless-mathematica/src/boxes/boxbox"

import { cellTypesHighlight } from "../libs/priceless-mathematica/src/sugar/cells"


const languageConf = new Compartment

const extras = []

if (!window.EditorGlobalExtensions) window.EditorGlobalExtensions = [];

/// A default highlight style (works well with light themes).
const defaultHighlightStyle = HighlightStyle.define([
  {tag: tags.meta,
   color: "var(--editor-key-meta)"},
  {tag: tags.link,
   textDecoration: "underline"},
  {tag: tags.heading,
   textDecoration: "underline",
   fontWeight: "bold"},
  {tag: tags.emphasis,
   fontStyle: "italic"},
  {tag: tags.strong,
   fontWeight: "bold"},
  {tag: tags.strikethrough,
   textDecoration: "line-through"},
  {tag: tags.keyword,
   color: "var(--editor-key-keyword)"},
  {tag: [tags.atom, tags.bool, tags.url, tags.contentSeparator, tags.labelName],
   color: "var(--editor-key-atom)"},
  {tag: [tags.literal, tags.inserted],
   color: "var(--editor-key-literal)"},
  {tag: [tags.string, tags.deleted],
   color: "var(--editor-key-string)"},
  {tag: [tags.regexp, tags.escape, tags.special(tags.string)],
   color: "var(--editor-key-escape)"},
  {tag: tags.definition(tags.variableName),
   color: "var(--editor-key-variable)"},
  {tag: tags.local(tags.variableName),
   color: "var(--editor-local-variable)"},
  {tag: [tags.typeName, tags.namespace],
   color: "var(--editor-key-type)"},
  {tag: tags.className,
   color: "var(--editor-key-class)"},
  {tag: [tags.special(tags.variableName), tags.macroName],
   color: "var(--editor-special-variable)"},
  {tag: tags.definition(tags.propertyName),
   color: "var(--editor-key-property)"},
  {tag: tags.comment,
   color: "var(--editor-key-comment)"},
  {tag: tags.invalid,
   color: "var(--editor-key-invalid)"}
])



const EditorAutocomplete = defaultFunctions;
EditorAutocomplete.extend = (list) => {
  window.EditorAutocomplete.push(...list);
  wolframLanguage.reBuild(window.EditorAutocomplete);
}

core.FrontAddDefinition = async (args, env) => {
  const data = await interpretate(args[0], env);
  console.log(data);
  
  data.forEach((element)=>{
    const name = element[0];
    const context = element[1];

    if (!(name in core.FrontAddDefinition.symbols)) {
      window.EditorAutocomplete.extend([  
        {
            "label": name,
            "type": "keyword",
            "info": "User's defined symbol in "+context  
        }]);

      core.FrontAddDefinition.symbols[name] = context;
    }
  });


}

core.FrontAddDefinition.symbols = {};

console.log('loaded!');

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

//----





//----

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
let selectedCell = undefined;

const EditorSelected = {
  get: () => {
    if (!selectedCell) return '';
    if (!selectedCell.editor.viewState) return '';
    const ranges = selectedCell.editor.viewState.state.selection.ranges;
    if (!ranges.length) return '';

    const selection = ranges[0];
    console.log('yoko');
    console.log(selection);
    console.log(selectedCell.editor.state.doc.toString().slice(selection.from, selection.to));
    console.log('processing');
    return selectedCell.editor.state.doc.toString().slice(selection.from, selection.to);
  },

  set: (data) => {
    if (!selectedCell) return;
    if (!selectedCell.editor.viewState) return;
    const ranges = selectedCell.editor.viewState.state.selection.ranges;
    if (!ranges.length) return;

    const selection = ranges[0];

    console.log('result');
      console.log(data);
      selectedCell.editor.dispatch({
        changes: {...selection, insert: data}
      });
  }
}

if (window.electronAPI) {
  window.electronAPI.contextMenu((event, id) => {
    if (!selectedCell) return;
    if (!selectedCell.editor.viewState) return;
    const ranges = selectedCell.editor.viewState.state.selection.ranges;
    if (!ranges.length) return;

    const selection = ranges[0];
    console.log('yoko');
    console.log(selection);
    console.log(selectedCell.editor.state.doc.toString().slice(selection.from, selection.to));
    console.log('processing');
    const substr = selectedCell.editor.state.doc.toString().slice(selection.from, selection.to).replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"');



    selectedCell.origin.evalString(id + '[' + substr + ']').then((res) => {
      console.log('result');
      console.log(res);
      selectedCell.editor.dispatch({
        changes: {...selection, insert: res.slice(1,-1)}
      });
    })
  });
}

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
    FractionBoxWidget(compactWLEditor),
    SqrtBoxWidget(compactWLEditor),
    SubscriptBoxWidget(compactWLEditor),
    SupscriptBoxWidget(compactWLEditor),
    GridBoxWidget(compactWLEditor),
    ViewBoxWidget(compactWLEditor),
    BoxBoxWidget(compactWLEditor),
    bracketMatching(),
    rainbowBrackets(),
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
  FractionBoxWidget(compactWLEditor),
  SqrtBoxWidget(compactWLEditor),
  SubscriptBoxWidget(compactWLEditor),
  SupscriptBoxWidget(compactWLEditor),
  GridBoxWidget(compactWLEditor),
  ViewBoxWidget(compactWLEditor),
  BoxBoxWidget(compactWLEditor),  
  bracketMatching(),
  rainbowBrackets(),
  Greekholder,
  Arrowholder,
  extras
]



import { defaultKeymap } from "@codemirror/commands";

let editorCustomTheme = EditorView.theme({
  "&.cm-focused": {
    outline: "1px dashed var(--editor-outline)", 
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

  ".rainbow-bracket-red": { color: 'var(--editor-bracket-1)' },
  ".rainbow-bracket-orange": { color: 'var(--editor-bracket-2)' },
  ".rainbow-bracket-yellow": { color: 'var(--editor-bracket-3)' },
  ".rainbow-bracket-green": { color: 'var(--editor-bracket-4)' },
  ".rainbow-bracket-blue": { color: 'var(--editor-bracket-5)' },
  ".rainbow-bracket-indigo": { color: 'var(--editor-bracket-6)' },
  ".rainbow-bracket-violet": { color: 'var(--editor-bracket-7)' },

  ".rainbow-bracket-red > span": { color: 'var(--editor-bracket-1-a)' },
  ".rainbow-bracket-orange > span": { color: 'var(--editor-bracket-2-a)' },
  ".rainbow-bracket-yellow > span": { color: 'var(--editor-bracket-3-a)' },
  ".rainbow-bracket-green > span": { color: 'var(--editor-bracket-4-a)' },
  ".rainbow-bracket-blue > span": { color: 'var(--editor-bracket-5-a)' },
  ".rainbow-bracket-indigo > span": { color: 'var(--editor-bracket-6-a)' },
  ".rainbow-bracket-violet > span": { color: 'var(--editor-bracket-7-a)' }

});

let editorCustomThemeCompact = EditorView.theme({
  "&.cm-focused": {
    outline: "1px dashed var(--editor-outline)",
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
  },

  ".rainbow-bracket-red": { color: 'var(--editor-bracket-1)' },
  ".rainbow-bracket-orange": { color: 'var(--editor-bracket-2)' },
  ".rainbow-bracket-yellow": { color: 'var(--editor-bracket-3)' },
  ".rainbow-bracket-green": { color: 'var(--editor-bracket-4)' },
  ".rainbow-bracket-blue": { color: 'var(--editor-bracket-5)' },
  ".rainbow-bracket-indigo": { color: 'var(--editor-bracket-6)' },
  ".rainbow-bracket-violet": { color: 'var(--editor-bracket-7)' },

  ".rainbow-bracket-red > span": { color: 'var(--editor-bracket-1-a)' },
  ".rainbow-bracket-orange > span": { color: 'var(--editor-bracket-2-a)' },
  ".rainbow-bracket-yellow > span": { color: 'var(--editor-bracket-3-a)' },
  ".rainbow-bracket-green > span": { color: 'var(--editor-bracket-4-a)' },
  ".rainbow-bracket-blue > span": { color: 'var(--editor-bracket-5-a)' },
  ".rainbow-bracket-indigo > span": { color: 'var(--editor-bracket-6-a)' },
  ".rainbow-bracket-violet > span": { color: 'var(--editor-bracket-7-a)' }

});

let globalCMFocus = false;

if (!window.EditorEpilog) window.EditorEpilog = [];

window.EditorExtensionsMinimal = [
  () => highlightSpecialChars(),
  () => history(),
  () => drawSelection(),
  () => dropCursor(),
  () => indentOnInput(),
  () => bracketMatching(),
  () => closeBrackets(),
  () => EditorView.lineWrapping,
  () => autocompletion(),
  () => syntaxHighlighting(defaultHighlightStyle, { fallback: false }),
  () => highlightSelectionMatches()
] 

window.EditorParameters = {

};

window.EditorExtensions = [
  () => highlightSpecialChars(),
  () => history(),
  () => drawSelection(),
  () => dropCursor(),
  () => {
      if (window.EditorParameters["gutter"])
        return lineNumbers();

      return [];
    },
  () => indentOnInput(),
  () => bracketMatching(),
  () => closeBrackets(),
  () => EditorView.lineWrapping,
  () => autocompletion(),
  () => syntaxHighlighting(defaultHighlightStyle, { fallback: false }),
  () => highlightSelectionMatches(),
  () => cellTypesHighlight,
  () => placeholder('Type Wolfram Expression / .md / .html / .js'),
  
  (self, initialLang) => languageConf.of(initialLang),
  () => autoLanguage, 
  
  (self, initialLang) => keymap.of([indentWithTab,
    { key: "Backspace", run: function (editor, key) { 
      if(editor.state.doc.length === 0) { self.origin.remove() }  
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
      self.origin.focusPrev(self.origin);

      editor.editorLastCursor = editor.state.selection.ranges[0].to;  
    } },
    { key: "ArrowDown", run: function (editor, key) { 
      console.log('arrowdown');
      console.log(editor.state.selection.ranges[0]);
      if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
      self.origin.focusNext(self.origin);

      editor.editorLastCursor = editor.state.selection.ranges[0].to;  
    } },
    { key: "Shift-Enter", preventDefault: true, run: function (editor, key) { 
      console.log(editor.state.doc.toString()); 
      self.origin.eval(editor.state.doc.toString()); 
    } }
    , ...defaultKeymap, ...historyKeymap
  ]),
  
  (self, initialLang) => EditorView.updateListener.of((v) => {
    if (v.docChanged) {
      //TODO: TOO SLOW FIXME!!!
      self.origin.save(v.state.doc.toString().replaceAll('\\\\', '\\\\\\\\').replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"'));
    }
    if (v.selectionSet) {
      selectedCell = self;
    }
    
  }),
  () => editorCustomTheme
];

function unicodeToChar(text) {
  return text.replace(/\\:[\da-f]{4}/gi, 
         function (match) {
              return String.fromCharCode(parseInt(match.replace(/\\:/g, ''), 16));
         });
}

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

      const self = this;

      const editor = new EditorView({
        doc: unicodeToChar(data),
        extensions: window.EditorExtensions.map((e) => e(self, initialLang)),
        parent: this.origin.element
      });
      
      this.editor = editor;
      this.editor.viewState.state.config.eval = () => {
        origin.eval(this.editor.state.doc.toString());
      };
  
      if(globalCMFocus) editor.focus();
      globalCMFocus = false;  

      window.EditorEpilog.forEach((e) => e(self, initialLang));
      
      
      
      return this;
    }
  }

  core.ReadOnly = () => "ReadOnly"

  //for dynamics
  core.EditorView = async (args, env) => {
    //cm6 inline editor (editable or read-only)
    const textData = await interpretate(args[0], env);
    const options = await core._getRules(args, env);

    let updateFunction = () => {};

    const ext = [];
    if (options.ReadOnly) {
      ext.push(EditorState.readOnly.of(true))
    }

    if (options.Event) {
      //then it means this is like a slider
      updateFunction = (data) => {
        console.log('editor view emitt data: '+data);
        server.emitt(options.Event, '"'+data.replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"')+'"');
      }
      
    }

    if (env.local) {
      //if it is running in a container
      env.local.editor = compactWLEditor({doc: textData, parent: env.element, eval: ()=>{}, update: updateFunction, extensions: ext});
    } else {
      compactWLEditor({doc: textData, parent: env.element, eval: ()=>{}, update: updateFunction, extensions: ext});
    }

    env.element.style.verticalAlign = "inherit";
    
  }

  core.StripOnInput = async () => {
    
  }

  core.EditorView.update = async (args, env) => {
    if (!env.local.editor) return;
    const textData = await interpretate(args[0], env);
    console.log('editor view: dispatch');
    env.local.editor.dispatch({
      changes: {from: 0, to: env.local.editor.state.doc.length, insert: textData}
    });
  }

  core.EditorView.destroy = async (args, env) => {
    const textData = await interpretate(args[0], env);
    if (env.local) {
      if (env.local.editor) {
        env.local.editor.destroy();
      }
    }
  }

  core.PreviewCell = (element, data) => {

  }
  
  window.SupportedLanguages.push({
    check: (r) => {return (r === null)},
    legacy: true, 
    plugins: mathematicaPlugins,
    name: 'mathematica'
  });

  window.EditorMathematicaPlugins = mathematicaPlugins

  window.SupportedCells['codemirror'] = {
    view: CodeMirrorCell
  };

  window.javascriptLanguage = javascriptLanguage
  window.javascript = javascript
  window.markdownLanguage = markdownLanguage
  window.markdown = markdown
  window.htmlLanguage = htmlLanguage
  window.html = html

  window.cssLanguage = cssLanguage
  window.css = css

  window.EditorView = EditorView
  window.highlightSpecialChars = highlightSpecialChars
  window.EditorState = EditorState
  window.syntaxHighlighting = syntaxHighlighting
  window.defaultHighlightStyle = defaultHighlightStyle
  window.editorCustomTheme = editorCustomTheme

  if (window.OfflineMode)
    extras.push(window.EditorState.readOnly.of(true))


core.FrontEditorSelected = async (args, env) => {
  const op = await interpretate(args[0], env);
  if (op == "Get")
    return EditorSelected.get();
  
  if (op == "Set") {
    let data = await interpretate(args[1], env);
    if (data.charAt(0) == '"') data = data.slice(1,-1);
    EditorSelected.set(data);
  }
}
