import 'dart:convert';
import 'dart:io';

import 'package:lsp_server/lsp_server.dart';
// import 'package:json_rpc_2/json_rpc_2.dart';
// import 'package:win32/win32.dart';
// import 'package:ffi/ffi.dart';

// 编译：dart compile exe bin/lsp_helper.dart

void printDebug(Object? object) {
  if (object != null) {
    print('[DEBUG] $object');
  }
}

String? getDartFullPath() {
  for (final String path
      in Platform.environment["PATH"]?.split(Platform.isWindows ? ";" : ":") ??
          []) {
    final file = File(
        "$path\${Platform.pathSeparator}dart");
    //print("file=	${file.path}");
    if (file.existsSync()) return file.path;
  }
  return null;
}

void main(List<String> args) async {
  // 第一个参数为dart的路径
  // zed的设置文件settings.json
  // "lsp": {
  //    "dart": { "binary": { "path":"<your path>/lsp_helper", "arguments":[ "your dart fullpath(Optional)" ] }}
  //}
  final dartProcess = await Process.start(
    args.firstOrNull ??
        getDartFullPath() ??
        "dart",
    ['language-server', '--protocol=lsp'],
    mode: ProcessStartMode.normal,
  );
  // 桥接的中间lsp服务
  var lspBridge = Connection(stdin, stdout);
  // 连接原dart的lsp服务
  var dartLsp = Connection(dartProcess.stdout, dartProcess.stdin);
  // 监听dart lsp的主动消息？？？
  //dartLsp.onNotification(method, handler)
  dartLsp.peer.registerFallback((parameters) {
    printDebug(
        "dartLsp method=	${parameters.method}, value=	${parameters.value}");
    // lspBridge.sendDiagnostics();
    // 这里应该这样做？？？？我也不知道！
    return lspBridge.sendNotification(parameters.method, parameters.value);
  });
  // 转发其它请求
  lspBridge.peer.registerFallback((parameters) async {
    printDebug(
        "收到zed消息：method=${parameters.method}, value=${parameters.value}");
    try {
      final res =
          await dartLsp.sendRequest(parameters.method, parameters.value);

      printDebug(
          "请求dart成功，返回结果：method=${parameters.method}, value=	$res, type=${res?.runtimeType}");
      if (parameters.method == "initialize") {
        // printDebug("收到初始消息=$res");
        // res["capabilities"]["completionProvider"] = {
        //   "resolveProvider": true,
        //   "triggerCharacters": ["."]
        // };
        // printDebug("修改后的结果=$res");
        return initializeResultJson;
      } else if (parameters.method == "shutdown") {
        dartLsp.close();
        lspBridge.close();
        dartProcess.kill();
      }
      return res;
    } catch (e) {
      printDebug(
          "请求dart错误 method=${parameters.method}, value=${parameters.value}, 异常=	$e");
    }
  });

  dartLsp.listen();
  await lspBridge.listen();
}

/// 拿了一段固定的返回结果
final initializeResultJson = jsonDecode(
    '{"capabilities":{"textDocumentSync":{"change":2},"selectionRangeProvider":true,"hoverProvider":{},"completionProvider":{"resolveProvider":true,"triggerCharacters":["."],"}}","documentFormattingProvider":true,"documentRangeFormattingProvider":true,"renameProvider":{"prepareProvider":true},"foldingRangeProvider":true,"inlayHintProvider":true,"linkedEditingRangeProvider":true},"serverInfo":{"name":"Dart Language Server"}}');