import * as vscode from "vscode";
import { rpgle_declarations } from "./reserved_words";

export function activate(context: vscode.ExtensionContext) {

  const greenDecoration = vscode.window.createTextEditorDecorationType({
    color: "green",
    fontWeight: "bold",
  });
  const color_declare = vscode.window.createTextEditorDecorationType({
    color: "#FF1744",
    fontWeight: "bold",
  });
  const color_control_options = vscode.window.createTextEditorDecorationType({
    color: "red",
    fontWeight: "bold",
  });
  const color_numbers = vscode.window.createTextEditorDecorationType({
    color: "#3949AB",
    fontWeight: "bold",
  });

  function dec_colors_numbers(decobj: vscode.TextEditor) {
    if (!decobj || decobj.document.languageId !== "rpgle") {
      return;
    }
    const build_regex = /\b\d+\b/gi;
    const text = decobj.document.getText();
    const decorations: vscode.DecorationOptions[] = [];
    let match;
    while ((match = build_regex.exec(text))) {
      const startPos = decobj.document.positionAt(match.index);
      const endPos = decobj.document.positionAt(match.index + match[0].length);
      decorations.push({ range: new vscode.Range(startPos, endPos) });
    }
    decobj.setDecorations(color_numbers, decorations);
  }

  function declaration_decorators(decobj: vscode.TextEditor) {
    if (!decobj || decobj.document.languageId !== "rpgle") {
      return;
    }
    const tags = rpgle_declarations.map((item) => item.tag.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'));
    const patron = `(${tags.join('|')})`;
    const build_regex = new RegExp(patron, 'g');
    const text = decobj.document.getText();
    const decorations: vscode.DecorationOptions[] = [];
    let match;
    while ((match = build_regex.exec(text))) {
      const startPos = decobj.document.positionAt(match.index);
      const endPos = decobj.document.positionAt(match.index + match[0].length);
      decorations.push({ range: new vscode.Range(startPos, endPos) });
    }
    decobj.setDecorations(color_declare, decorations);
  }

  vscode.window.onDidChangeActiveTextEditor(
    (editor) => {
      if (editor) {
        declaration_decorators(editor);
        dec_colors_numbers(editor);
      }
    },
    null,
    context.subscriptions,
  );

  vscode.workspace.onDidChangeTextDocument(
    (event) => {
      const editor = vscode.window.activeTextEditor;
      if (editor && event.document === editor.document) {
        declaration_decorators(editor);
        dec_colors_numbers(editor);
      }
    },
    null,
    context.subscriptions,
  );

  if (vscode.window.activeTextEditor) {
    declaration_decorators(vscode.window.activeTextEditor);
    dec_colors_numbers(vscode.window.activeTextEditor);
  }
}
