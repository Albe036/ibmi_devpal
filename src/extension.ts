import * as vscode from 'vscode';

export function activate(context: vscode.ExtensionContext) {
    console.log('🚀 ¡IBM i DevPal ha despertado en 2026!');

    // Decoration para colorear 'dcl-s' en verde en archivos .rpgle
    const greenDecoration = vscode.window.createTextEditorDecorationType({
        color: 'green',
        fontWeight: 'bold'
    });

    function updateDecorations(editor: vscode.TextEditor) {
        if (!editor || editor.document.languageId !== 'rpgle') return;
        const regEx = /\bdcl-s\b/gi;
        const text = editor.document.getText();
        const decorations: vscode.DecorationOptions[] = [];
        let match;
        while ((match = regEx.exec(text))) {
            const startPos = editor.document.positionAt(match.index);
            const endPos = editor.document.positionAt(match.index + match[0].length);
            decorations.push({ range: new vscode.Range(startPos, endPos) });
        }
        editor.setDecorations(greenDecoration, decorations);
    }

    vscode.window.onDidChangeActiveTextEditor(editor => {
        if (editor) updateDecorations(editor);
    }, null, context.subscriptions);

    vscode.workspace.onDidChangeTextDocument(event => {
        const editor = vscode.window.activeTextEditor;
        if (editor && event.document === editor.document) {
            updateDecorations(editor);
        }
    }, null, context.subscriptions);

    if (vscode.window.activeTextEditor) {
        updateDecorations(vscode.window.activeTextEditor);
    }
}