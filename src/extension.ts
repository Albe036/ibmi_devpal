import * as vscode from "vscode";

export function activate(context: vscode.ExtensionContext) {
  console.log("🚀 ¡IBM i DevPal ha despertado en 2026!");

  // Decoration para colorear 'dcl-s' en verde en archivos .rpgle
  const greenDecoration = vscode.window.createTextEditorDecorationType({
    color: "green",
    fontWeight: "bold",
  });
  const color_declare = vscode.window.createTextEditorDecorationType({
    color: "red",
    fontWeight: "bold",
  });
  const color_control_options = vscode.window.createTextEditorDecorationType({
    color: "red",
    fontWeight: "bold",
  });

  //function updateDecorations(editor: vscode.TextEditor) {
  //    if (!editor || editor.document.languageId !== 'rpgle') return;
  //    const regEx = /\bdcl-s\b/gi;
  //    const text = editor.document.getText();
  //    const decorations: vscode.DecorationOptions[] = [];
  //    let match;
  //    while ((match = regEx.exec(text))) {
  //        const startPos = editor.document.positionAt(match.index);
  //        const endPos = editor.document.positionAt(match.index + match[0].length);
  //        decorations.push({ range: new vscode.Range(startPos, endPos) });
  //    }
  //    editor.setDecorations(greenDecoration, decorations);
  //}

  function declaration_decorators(decobj: vscode.TextEditor) {
    if (!decobj || decobj.document.languageId !== "rpgle") {
      return;
    }
    const build_regex = /\bdcl-f\b/gi;
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
      }
    },
    null,
    context.subscriptions,
  );

  if (vscode.window.activeTextEditor) {
    declaration_decorators(vscode.window.activeTextEditor);
  }
}
