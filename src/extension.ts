
import * as vscode from "vscode";
import { rpgle_declarations, rpgleDataTypes, rpgle_definitions_keywords, rpgle_declare_block_endings } from "./reserved_words";

export function activate(context: vscode.ExtensionContext) {
  const decorations = [
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#9E9E9E" }),
        regex: () => /^(.{1,8})/gmi,
    },
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#9E9E9E" }),
        regex: () => /^.{79}(.+)/gmi,
    },
    {
      type: vscode.window.createTextEditorDecorationType({ color: "#FF1744" }),
      regex: () => {
        const tags = rpgle_declarations.map((item) => item.tag.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
        return new RegExp(`\\b(${tags.join("|")})\\b`, "gi");
      },
    },
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#FF1744" }),
        regex: () => {
            const tags_declaration = rpgle_declare_block_endings.declarations.map((item) => item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_logic = rpgle_declare_block_endings.logicControl.map((item) => item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_loops = rpgle_declare_block_endings.loops.map((item) => item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const all_tags_start = [...tags_declaration, ...tags_logic, ...tags_loops];
            const tags_declaration_end = rpgle_declare_block_endings.declarations.map((item) => item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_logic_end = rpgle_declare_block_endings.logicControl.map((item) => item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_loops_end = rpgle_declare_block_endings.loops.map((item) => item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const all_tags_end = [...tags_declaration_end, ...tags_logic_end, ...tags_loops_end];
            const all_tags = [...all_tags_start, ...all_tags_end];
            return new RegExp(`\\b(${all_tags.join("|")})\\b`, "gi");
        }
    },
    {
      type: vscode.window.createTextEditorDecorationType({ color: "#3949AB" }),
      regex: () => /\b\d+\b/gi,
    },
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#43A047" }),
        regex: () => /(['"])(.*?)\1/gi,
    },
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#E6EE9C" }),
        regex: ()=> {
            const tags = rpgleDataTypes.map((item) => item.tag.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            return new RegExp(`\\b(${tags.join("|")})\\b`, "gi");
        }
    },
    {
        type: vscode.window.createTextEditorDecorationType({ color: "#E6EE9C" }),
        regex: () => {
            const tags_structural = rpgle_definitions_keywords.structural.map((item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_initialization = rpgle_definitions_keywords.initialization.map((item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const tags_parameters = rpgle_definitions_keywords.parameters.map((item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"));
            const all_tags = [...tags_structural, ...tags_initialization, ...tags_parameters];
            return new RegExp(`\\b(${all_tags.join("|")})\\b`, "gi");
        }
    },
    
  ];

  function applyDecorations(editor: vscode.TextEditor) {
    if (!editor || editor.document.languageId !== "rpgle") return;
    const text = editor.document.getText();
    decorations.forEach(({ type, regex }) => {
      const reg = regex();
      const decs: vscode.DecorationOptions[] = [];
      let match;
      while ((match = reg.exec(text))) {
        const start = editor.document.positionAt(match.index);
        const end = editor.document.positionAt(match.index + match[0].length);
        decs.push({ range: new vscode.Range(start, end) });
      }
      editor.setDecorations(type, decs);
    });
  }

  const triggerDecorations = (editor?: vscode.TextEditor) => {
    applyDecorations(editor ?? vscode.window.activeTextEditor!);
  };

  vscode.window.onDidChangeActiveTextEditor(triggerDecorations, null, context.subscriptions);
  vscode.workspace.onDidChangeTextDocument(
    (e) => {
      if (vscode.window.activeTextEditor && e.document === vscode.window.activeTextEditor.document) {
        triggerDecorations(vscode.window.activeTextEditor);
      }
    },
    null,
    context.subscriptions
  );

  if (vscode.window.activeTextEditor) {
    triggerDecorations(vscode.window.activeTextEditor);
  }
}
