import {
  EditorView,
  Decoration,
  ViewPlugin,
  WidgetType,
  MatchDecorator
} from "@codemirror/view";

const GreekMatcher = new MatchDecorator({
  regexp: /\\\[(\w+)\]/g,
  decoration: (match) => {
    //console.log(match);
    return Decoration.replace({
      widget: new GreekWidget(match[1])
    })
  }
});

export const Greekholder = ViewPlugin.fromClass(
  class {
    constructor(view) {
      this.Greekholder = GreekMatcher.createDeco(view);
    }
    update(update) {
      this.Greekholder = GreekMatcher.updateDeco(update, this.Greekholder);
    }
  },
  {
    decorations: instance => instance.Greekholder,
    provide: plugin => EditorView.atomicRanges.of(view => {
      return view.plugin(plugin)?.Greekholder || Decoration.none
    })
  }
);

class GreekWidget extends WidgetType {
  constructor(name) {
    //console.log('created');
    super();
    this.name = name;
  }

  eq(other) {
    return this.name === other.name;
  }

  toDOM() {
    //console.log('to DOM');
    let elt = document.createElement("span");
    elt.innerHTML =
      "&" +
      this.name
        .toLowerCase()
        .replace("sqrt", "radic")
        .replace("undirectededge", 'harr')
        .replace('directededge', 'rarr')
        .replace(/capital(.*)/, (arg, rep) => {
          return rep.charAt(0).toUpperCase() + rep.slice(1);
        })
        .replace(/curly(.*)/, (arg, rep) => {
          return rep;
        })
        .replace(/script(.*)/, (arg, rep) => {
          return 'el'+rep.toLowerCase();
        })
        .replace('transpose', '#7488')
        .replace("degree", "deg") +
      ";";

    return elt;
  }
  ignoreEvent() {
    return false;
  }
}

const ArrowMatcher = new MatchDecorator({
  regexp: /(->|<-)/g,
  decoration: (match) =>
    Decoration.replace({
      widget: new ArrowWidget(match[1])
    })
});
export const Arrowholder = ViewPlugin.fromClass(
  class {
    constructor(view) {
      this.Arrowholder = ArrowMatcher.createDeco(view);
    }
    update(update) {
      this.Arrowholder = ArrowMatcher.updateDeco(update, this.Arrowholder);
    }
  },
  {
    decorations: (instance) => instance.Arrowholder,
    provide: (plugin) =>
      EditorView.atomicRanges.of((view) => {
        return view.plugin(plugin)?.Arrowholder || Decoration.none;
      })
  }
);

class ArrowWidget extends WidgetType {
  constructor(dir) {
    super();
    this.dir = dir;
    //this.instance = Math.random();
  }
  eq(other) {
    return this.dir === other.dir;
  }
  toDOM() {
    let elt = document.createElement("span");
    //console.log(this.dir);
    if (this.dir === "->") {
      elt.innerText = "→";
    } else {
      elt.innerText = "←";
    }

    return elt;
  }
  ignoreEvent() {
    return false;
  }
}
