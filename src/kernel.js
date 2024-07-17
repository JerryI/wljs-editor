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

import { DropPasteHandlers } from "../libs/priceless-mathematica/src/mathematica/dropevents";

import { Greekholder } from "../libs/priceless-mathematica/src/sugar/misc"

import {FractionBoxWidget} from "../libs/priceless-mathematica/src/boxes/fractionbox"
import {SqrtBoxWidget} from "../libs/priceless-mathematica/src/boxes/sqrtbox"
import {SubscriptBoxWidget} from "../libs/priceless-mathematica/src/boxes/subscriptbox"
import {SupscriptBoxWidget} from "../libs/priceless-mathematica/src/boxes/supscriptbox"
import {GridBoxWidget} from "../libs/priceless-mathematica/src/boxes/gridbox"

import {ViewBoxWidget} from "../libs/priceless-mathematica/src/boxes/viewbox"
import {BoxBoxWidget} from "../libs/priceless-mathematica/src/boxes/boxbox"
import {TemplateBoxWidget} from "../libs/priceless-mathematica/src/boxes/templatebox"

import { cellTypesHighlight } from "../libs/priceless-mathematica/src/sugar/cells"






const languageConf = new Compartment

const readWriteCompartment = new Compartment

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



window.EditorAutocomplete = defaultFunctions;
EditorAutocomplete.extend = (list) => {
  window.EditorAutocomplete.push(...list);
  wolframLanguage.reBuild(window.EditorAutocomplete);
}

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


//----





//----
 

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

let compactWLEditor = null;
let selectedEditor = undefined;

const EditorSelected = {
  type: (e) => {
    const editor = e || selectedEditor;

    if (!editor) return '';
    if (!editor.viewState) return '';
    console.log();
    return checkDocType(editor.state.doc.line(1).text).name;
  },
  cursor: (e) => {
    const editor = e || selectedEditor;

    if (!editor) return '';
    if (!editor.viewState) return '';
    const ranges = editor.viewState.state.selection.ranges;
    if (!ranges.length) return false;  
    const selection = ranges[0];
    return [selection.from, selection.to];  
  },
  getContent: (e) => {
    const editor = e || selectedEditor;

    if (!editor) return '';
    if (!editor.viewState) return '';
    return editor.state.doc.toString();
  },  
  get: (e) => {
    const editor = e || selectedEditor;


    if (!editor) return '';
    if (!editor.viewState) return '';
    const ranges = editor.viewState.state.selection.ranges;
    if (!ranges.length) return '';

    const selection = ranges[0];
    console.log('yoko');
    console.log(selection);
    console.log(editor.state.doc.toString().slice(selection.from, selection.to));
    console.log('processing');
    return editor.state.doc.toString().slice(selection.from, selection.to);
  },

  set: (data, e) => {
    const editor = e || selectedEditor;

    if (!editor) return;
    if (!editor.viewState) return;
    const ranges = editor.viewState.state.selection.ranges;
    if (!ranges.length) return;

    const selection = ranges[0];

    console.log('result');
      console.log(data);
      editor.dispatch({
        changes: {...selection, insert: data}
      });
  },

  currentEditor: () => {
    return selectedEditor;
  },

  setContent: (data, e) => {
    const editor = e || selectedEditor;

    if (!editor) return;
    if (!editor.viewState) return;


    console.log('result');
      console.log(data);
      editor.dispatch({
        changes: {
          from: 0,
          to: editor.viewState.state.doc.length
        , insert: data}
      });
  }
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
    FractionBoxWidget(compactWLEditor),
    SqrtBoxWidget(compactWLEditor),
    SubscriptBoxWidget(compactWLEditor),
    SupscriptBoxWidget(compactWLEditor),
    GridBoxWidget(compactWLEditor),
    ViewBoxWidget(compactWLEditor),
    BoxBoxWidget(compactWLEditor),
    TemplateBoxWidget(compactWLEditor),
    bracketMatching(),
    //rainbowBrackets(),
    Greekholder,
    extras,
    
    EditorView.updateListener.of((v) => {
      if (v.docChanged) {
        args.update(v.state.doc.toString());
      }
      if (v.selectionSet) {
        //console.log('selected editor:');
        //console.log(v.view);
        selectedEditor = v.view;
      }
    })
  ],
  parent: args.parent
  });

  editor.viewState.state.config.eval = args.eval;
  return editor;
}

const wlDrop = {
    transaction: (ev, view, id, length) => {
      console.log(view.dom.ocellref);
      if (view.dom.ocellref) {
        const channel = view.dom.ocellref.origin.channel;
        server._emitt(channel, `<|"Channel"->"${id}", "Length"->${length}, "CellType"->"wl"|>`, 'Forwarded["CM:DropEvent"]');
      }
    },

    file: (ev, view, id, name, result) => {
      console.log(view.dom.ocellref);
      if (view.dom.ocellref) {
        server.emitt(id, `<|"Data"->"${result}", "Name"->"${name}"|>`, 'File');
      }
    }
}

const wlPaste = {
  transaction: (ev, view, id, length) => {
    console.log(view.dom.ocellref);
    if (view.dom.ocellref) {
      const channel = view.dom.ocellref.origin.channel;
      server._emitt(channel, `<|"Channel"->"${id}", "Length"->${length}, "CellType"->"wl"|>`, 'Forwarded["CM:PasteEvent"]');
    }
  },

  file: (ev, view, id, name, result) => {
    console.log(view.dom.ocellref);
    if (view.dom.ocellref) {
      server.emitt(id, `<|"Data"->"${result}", "Name"->"${name}"|>`, 'File');
    }
  }
}

window.DropPasteHandlers = DropPasteHandlers


const mathematicaPlugins = [
  wolframLanguage.of(window.EditorAutocomplete), 
  FractionBoxWidget(compactWLEditor),
  SqrtBoxWidget(compactWLEditor),
  SubscriptBoxWidget(compactWLEditor),
  SupscriptBoxWidget(compactWLEditor),
  GridBoxWidget(compactWLEditor),
  ViewBoxWidget(compactWLEditor),
  BoxBoxWidget(compactWLEditor),  
  TemplateBoxWidget(compactWLEditor),
  bracketMatching(),
  //rainbowBrackets(),
  Greekholder,
  extras,
  DropPasteHandlers(wlDrop, wlPaste)
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
/*
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
*/
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
  //() => closeBrackets(),
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
 // () => test(),
  //() => closeBrackets(),
  () => EditorView.lineWrapping,
  () => autocompletion(),
  () => syntaxHighlighting(defaultHighlightStyle, { fallback: false }),
  () => highlightSelectionMatches(),
  () => cellTypesHighlight,
  () => placeholder('Type Wolfram Expression / .md / .html / .js'),
  
  (self, initialLang) => languageConf.of(initialLang),
  () => readWriteCompartment.of(EditorState.readOnly.of(false)),
  () => autoLanguage, 
  
  (self, initialLang) => keymap.of([indentWithTab,
    { key: "Backspace", run: function (editor, key) { 
      if(editor.state.doc.length === 0) { self.origin.remove(); return true; }  
    } },
    { key: "ArrowLeft", run: function (editor, key) {  
      editor.editorLastCursor = editor.state.selection.ranges[0].to;  
    } },   
    { key: "ArrowRight", run: function (editor, key) {  
      editor.editorLastCursor = editor.state.selection.ranges[0].to;  
    } },                      
    { key: "ArrowUp", run: function (editor, key) {  
      //console.log('arrowup');
      //console.log(editor.state.selection.ranges[0]);
      if (editor?.editorLastCursor === editor.state.selection.ranges[0].to)
      self.origin.focusPrev(self.origin);

      editor.editorLastCursor = editor.state.selection.ranges[0].to;  
    } },
    { key: "ArrowDown", run: function (editor, key) { 
      //console.log('arrowdown');
      //console.log(editor.state.selection.ranges[0]);
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
      //console.log('selected editor:');
      //console.log(v.view);
      selectedEditor = v.view;
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

    setContent (data) {
      console.warn('content mutation!');
      if (!this.editor.viewState) return;
  //FIXME: NO CLEAN UP
  const editor = this.editor;
      console.log('result');
      console.log(data);
      this.editor.dispatch({
        changes: {
          from: 0,
          to: editor.viewState.state.doc.length
        , insert: ''}
    });      
      this.editor.dispatch({
          changes: {
            from: 0,
            to: editor.viewState.state.doc.length
          , insert: data}
      });
    }
  
    addDisposable(el) {
      this.trash.push(el);
    }
    
    dispose() {
      this.editor.destroy();
    }

    readOnly(state) {
      this.editor.dispatch({
        effects: readWriteCompartment.reconfigure(EditorState.readOnly.of(state))
      })
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
      this.editor.dom.ocellref = self;

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

  function unicodeToChar2(text) {
    return text.replace(/\\\\:[\da-f]{4}/gi, 
           function (match) {
                return String.fromCharCode(parseInt(match.replace(/\\\\:/g, ''), 16));
           });
  }

  //for dynamics
  core.EditorView = async (args, env) => {
    //cm6 inline editor (editable or read-only)
    const textData = unicodeToChar2(await interpretate(args[0], env));
    const options = await core._getRules(args, env);

    let evalFunction = () => {};

    let updateFunction = () => {};
    let state = textData;

    const ext = [];
    if (options.ReadOnly) {
      ext.push(EditorState.readOnly.of(true))
    }

    if (options.ForceUpdate) {
      env.local.forceUpdate = options.ForceUpdate
    }

    if (options.Event) {
      //then it means this is like a slider
      updateFunction = (data) => {
        state = data;
        console.log('editor view emitt data: '+data);
        server.kernel.emitt(options.Event, '"'+data.replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"')+'"', 'Input');
      }

      evalFunction = () => {
        server.kernel.emitt(options.Event, '"'+state.replaceAll('\\\"', '\\\\\"').replaceAll('\"', '\\"')+'"', 'Evaluate');
      }
      
    }

    if (env.local) {
      //if it is running in a container
      env.local.editor = compactWLEditor({doc: textData, parent: env.element, eval: evalFunction, update: updateFunction, extensions: ext});
    } else {
      compactWLEditor({doc: textData, parent: env.element, eval: evalFunction, update: updateFunction, extensions: ext});
    }

    env.element.style.verticalAlign = "inherit";
    
  }

  core.StripOnInput = async () => {
    
  }

  core.EditorView.update = async (args, env) => {
    if (!env.local.editor) return;
    const textData = unicodeToChar2(await interpretate(args[0], env));
    console.log('editor view: dispatch');
    if (env.local.forceUpdate) {
      env.local.editor.dispatch({
        changes: {from: 0, to: env.local.editor.state.doc.length, insert: ''}
      });
      env.local.editor.dispatch({
        changes: {from: 0, to: 0, insert: textData}
      });
    } else {
      env.local.editor.dispatch({
        changes: {from: 0, to: env.local.editor.state.doc.length, insert: textData}
      });
    }

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

  window.SupportedLanguages.push({
    check: (r) => {return(r[0].match(/\w+\.(wl|wls)$/) != null)},
    plugins:  mathematicaPlugins,
    legacy: true, 
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

function uuidv4() {
      return "10000000-1000-4000-8000-100000000000".replace(/[018]/g, c =>
        (+c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> +c / 4).toString(16)
      );
}    

const editorHashMap = {};

core.FrontEditorSelected = async (args, env) => {
  console.log('check');
  const op = await interpretate(args[0], env);
  const options = await core._getRules(args, env);
  let editor = undefined;

  if (options.Editor) {
    editor = editorHashMap[options.Editor];
    console.log('Editor');
    console.log(options.Editor);
    console.log(editor);
  }

  

  switch(op) {
    case 'Get':
      return EditorSelected.get(editor);
    break;

    case 'Set':
      let data = await interpretate(args[1], env);
      //if (data.charAt(0) == '"') data = data.slice(1,-1);
      EditorSelected.set(data, editor);
    break;

    case 'GetDoc':
      return EditorSelected.getContent(editor);
    break;

    case 'SetDoc':
      let data2 = await interpretate(args[1], env);
      //if (data2.charAt(0) == '"') data2 = data2.slice(1,-1);
      EditorSelected.setContent(data2, editor);
    break;

    case 'Cursor':
      return EditorSelected.cursor(editor);
    break;

    case 'Type':
      return EditorSelected.type(editor);
    break;    

    case 'Editor':
      const key = uuidv4();
      editorHashMap[key] = EditorSelected.currentEditor();
      return key;
    break;
  }
}
