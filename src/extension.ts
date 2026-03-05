import * as vscode from "vscode";
import {
  rpgle_declarations,
  rpgleDataTypes,
  rpgle_definitions_keywords,
  rpgle_declare_block_endings,
  figurative_constants,
  file_operations,
  control_options,
  ctlOptAttributes
} from "./reserved_words";

export function activate(context: vscode.ExtensionContext) {
  const decorations = [
    {
      //Margen inferior de 7 caracteres
      type: vscode.window.createTextEditorDecorationType({ color: "#9E9E9E" }),
      regex: () => /^(.{1,7})/gim,
    },
    {
      //comentarios
      type: vscode.window.createTextEditorDecorationType({ color: "#008080" }),
      regex: () => /(?<!:)\/\/.*/gim,
    },
    {
      //declaraciones simples
      type: vscode.window.createTextEditorDecorationType({ color: "#FF1744" }),
      regex: () => {
        const tags = rpgle_declarations.map((item) =>
          item.tag.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        return new RegExp(`\\b(${tags.join("|")})\\b`, "gi");
      },
    },
    {
      //declaraciones de bloques, control de lógica y loops
      type: vscode.window.createTextEditorDecorationType({ color: "#FF1744" }),
      regex: () => {
        const tags_declaration = rpgle_declare_block_endings.declarations.map(
          (item) => item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_logic = rpgle_declare_block_endings.logicControl.map(
          (item) => item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_loops = rpgle_declare_block_endings.loops.map((item) =>
          item.start.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const all_tags_start = [
          ...tags_declaration,
          ...tags_logic,
          ...tags_loops,
        ];
        const tags_declaration_end =
          rpgle_declare_block_endings.declarations.map((item) =>
            item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
          );
        const tags_logic_end = rpgle_declare_block_endings.logicControl.map(
          (item) => item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_loops_end = rpgle_declare_block_endings.loops.map((item) =>
          item.end.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const all_tags_end = [
          ...tags_declaration_end,
          ...tags_logic_end,
          ...tags_loops_end,
        ];
        const all_tags = [...all_tags_start, ...all_tags_end];
        return new RegExp(`\\b(${all_tags.join("|")})\\b`, "gi");
      },
    },
    {
      //textos
      type: vscode.window.createTextEditorDecorationType({ color: "#43A047" }),
      regex: () => /(['"])(.*?)\1/gi,
    },
    {
      //numeros
      type: vscode.window.createTextEditorDecorationType({ color: "#3949AB" }),
      regex: () => /\b\d+\b/gi,
    },
    {
      //tipo de datos
      type: vscode.window.createTextEditorDecorationType({ color: "#df5c5c" }),
      regex: () => {
        const tags = rpgleDataTypes.map((item) =>
          item.tag.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        return new RegExp(`\\b(${tags.join("|")})\\b`, "gi");
      },
    },
    {
      type: vscode.window.createTextEditorDecorationType({ color: "#df5c5c" }),
      regex: () => {
        const tags_structural = rpgle_definitions_keywords.structural.map(
          (item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_initialization =
          rpgle_definitions_keywords.initialization.map((item) =>
            item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
          );
        const tags_parameters = rpgle_definitions_keywords.parameters.map(
          (item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_file_specific = rpgle_definitions_keywords.fileSpecific.map(
          (item) => item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tag_data_types_attributes =
          rpgle_definitions_keywords.dataTypesAttributes.map((item) =>
            item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
          );
        const tags_attr_ctl_opt = ctlOptAttributes.map((item) =>
          item.tag.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const all_tags = [
          ...tags_structural,
          ...tags_initialization,
          ...tags_parameters,
          ...tags_file_specific,
          ...tag_data_types_attributes,
          ...tags_attr_ctl_opt
        ];
        return new RegExp(`\\b(${all_tags.join("|")})\\b`, "gi");
      },
    },
    {
      type: vscode.window.createTextEditorDecorationType({ color: "#d1d41b" }),
      regex: () => {
        const tags_figurative_constants = figurative_constants.map((item) =>
          item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_file_operations = file_operations.map((item) =>
          item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const tags_control_options = control_options.map((item) =>
          item.replace(/[.*+?^${}()|[\]\\]/g, "\\$&"),
        );
        const all_tags = [
          ...tags_figurative_constants,
          ...tags_file_operations,
          ...tags_control_options
        ];
        const patron = `\\b${all_tags.join("|")}\\b`;
        return new RegExp(patron, "gi");
      },
    },
  ];

  function applyDecorations(editor: vscode.TextEditor) {
    if (!editor || editor.document.languageId !== "rpgle") {
      return;
    }
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

  vscode.window.onDidChangeActiveTextEditor(
    triggerDecorations,
    null,
    context.subscriptions,
  );
  vscode.workspace.onDidChangeTextDocument(
    (e) => {
      if (
        vscode.window.activeTextEditor &&
        e.document === vscode.window.activeTextEditor.document
      ) {
        triggerDecorations(vscode.window.activeTextEditor);
      }
    },
    null,
    context.subscriptions,
  );

  if (vscode.window.activeTextEditor) {
    triggerDecorations(vscode.window.activeTextEditor);
  }
}
