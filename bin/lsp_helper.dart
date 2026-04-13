import 'dart:io';

import 'package:lsp_server/lsp_server.dart';

const initializeResultJson = {
  'capabilities': {
    'textDocumentSync': {'change': 2},
    'selectionRangeProvider': true,
    'hoverProvider': {},
    'completionProvider': {
      'resolveProvider': true,
      'triggerCharacters': ['.']
    },
    'signatureHelpProvider': {
      'triggerCharacters': ['('],
      'retriggerCharacters': [',']
    },
    'definitionProvider': {},
    'typeDefinitionProvider': true,
    'implementationProvider': true,
    'referencesProvider': true,
    'documentHighlightProvider': true,
    'documentSymbolProvider': {},
    'workspaceSymbolProvider': true,
    'codeActionProvider': {
      'codeActionKinds': ['quickfix', 'refactor']
    },
    'codeLensProvider': {},
    'documentFormattingProvider': {},
    'documentRangeFormattingProvider': {},
    'documentOnTypeFormattingProvider': {
      'firstTriggerCharacter': '}',
      'moreTriggerCharacter': [';']
    },
    'renameProvider': {'prepareProvider': true},
    'documentLinkProvider': {'resolveProvider': false},
    'colorProvider': {},
    'foldingRangeProvider': true,
    'executeCommandProvider': {
      'commands': [
        'dart.edit.sortMembers',
        'dart.edit.organizeImports',
        'dart.edit.fixAll'
      ],
      'workDoneProgress': true
    },
    'workspace': {
      'workspaceFolders': {'supported': true, 'changeNotifications': true}
    },
    'callHierarchyProvider': true,
    'semanticTokensProvider': {
      'legend': {
        'tokenTypes': [
          'annotation',
          'keyword',
          'class',
          'comment',
          'method',
          'variable'
        ],
        'tokenModifiers': ['documentation', 'constructor', 'static']
      },
      'range': true,
      'full': {'delta': false}
    },
    'inlayHintProvider': {'resolveProvider': false},
    'experimental': <String, dynamic>{}
  }
};

String? getDartFullPath() {
  for (final String path
      in Platform.environment["PATH"]?.split(Platform.isWindows ? ";" : ":") ??
          []) {
    final file = File("$path\${Platform.pathSeparator}dart");
    if (file.existsSync()) return file.path;
  }
  return null;
}

void main(List<String> args) async {
  final dartProcess = await Process.start(
    args.firstOrNull ?? getDartFullPath() ?? "dart",
    ['language-server', '--protocol=lsp'],
    mode: ProcessStartMode.normal,
  );

  var lspBridge = Connection(stdin, stdout);
  var dartLsp = Connection(dartProcess.stdout, dartProcess.stdin);

  dartLsp.peer.registerFallback((parameters) {
    printDebug(
        "dartLsp method: ${parameters.method}, value: ${parameters.value}");
    lspBridge.sendNotification(parameters.method, parameters.value);
  });

  lspBridge.peer.registerFallback((parameters) async {
    printDebug(
        "Received zed message: method: ${parameters.method}, value: ${parameters.value}");
    try {
      final res =
          await dartLsp.sendRequest(parameters.method, parameters.value);

      printDebug(
          "Request dart success, result: method: ${parameters.method}, value: $res, type: ${res?.runtimeType}");
      var result = res;
      if (parameters.method == "initialize") {
        result = {'capabilities': initializeResultJson['capabilities']};
      } else if (parameters.method == "shutdown") {
        dartLsp.close();
        lspBridge.close();
        dartProcess.kill();
      }
      return result;
    } catch (e) {
      printDebug(
          "Request dart error: method: ${parameters.method}, value: ${parameters.value}, error: $e");
    }
  });

  dartLsp.listen();
  await lspBridge.listen();
}

void printDebug(Object? object) {
  if (object != null) {
    print('[DEBUG] $object');
  }
}
