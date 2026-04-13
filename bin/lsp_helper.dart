// Assume the full original initializeResultJson is as follows:
const initializeResultJson = {
  capabilities: {
    textDocumentSync: 1,
    selectionRangeProvider: true,
    hoverProvider: true,
    completionProvider: {
      triggerCharacters: [".", "@"]
    },
    signatureHelpProvider: true,
    definitionProvider: true,
    typeDefinitionProvider: true,
    implementationProvider: true,
    referencesProvider: true,
    documentHighlightProvider: true,
    documentSymbolProvider: true,
    workspaceSymbolProvider: true,
    codeActionProvider: true,
    codeLensProvider: true,
    documentFormattingProvider: true,
    documentRangeFormattingProvider: true,
    documentOnTypeFormattingProvider: true,
    renameProvider: true,
    documentLinkProvider: true,
    colorProvider: true,
    foldingRangeProvider: true,
    executeCommandProvider: true,
    workspace: true,
    callHierarchyProvider: true,
    semanticTokensProvider: true,
    inlayHintProvider: true,
    experimental: {}
  }
};