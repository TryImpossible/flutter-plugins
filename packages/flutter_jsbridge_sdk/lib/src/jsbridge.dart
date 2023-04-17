import 'dart:async';
import 'dart:convert';

import 'jsbridge_model.dart';
import 'jsbridge_types.dart';

/// FlutterJSBridge
class JSBridge {
  JSBridgeMessageExecutor? _messageExecutor;

  /// 通道名称
  String get channelName => 'FlutterWebView';

  /// debug模式
  bool get debug => _debug;
  bool _debug = false;

  /// javascript-jsbridge-sdk是否嵌入
  bool get hasReady => _hasReady;
  bool _hasReady = false;

  /// 方法集合
  final Map<String, JSBridgeHandler> _handlers = <String, JSBridgeHandler>{};

  /// 回调集合
  final Map<int, Completer<Object?>> _completers = <int, Completer<Object?>>{};

  /// 打印日志
  void _log(String msg) {
    if (_debug) {
      print(msg);
    }
  }

  /// 初始化
  void init({
    required JSBridgeMessageExecutor messageExecutor,
    bool debug = false,
  }) {
    _messageExecutor = messageExecutor;
    _debug = debug;
    registerHandler<bool>('#jsbridgeReady#', (Object? data) async {
      _log('[#jsbridgeReady#] request: ${data.toString()}');
      _hasReady = true;
      return true;
    });
  }

  /// 注册方法
  void registerHandler<T extends Object?>(
    String handlerName,
    JSBridgeHandler<T> handler,
  ) {
    _handlers[handlerName] = handler;
  }

  /// 注销方法
  void unregisterHandler(String handlerName) {
    if (!_handlers.containsKey(handlerName)) {
      return;
    }
    _handlers.remove(handlerName);
  }

  /// 调用方法
  Future<T> callHandler<T extends Object?>(
    String handlerName, {
    Object? data,
  }) {
    return _receiverCall<T>(handlerName: handlerName, data: data);
  }

  /// 执行javaScript代码
  Future<T> evalJavaScript<T extends Object?>(String javaScript) {
    return callHandler<T>('#evalJavaScript#', data: javaScript);
  }

  /// 监听jsbridge消息
  void onMessageReceived(String messageString) {
    final String decodeString = Uri.decodeFull(messageString);
    final Map<String, dynamic> jsonData = jsonDecode(decodeString);
    _log('[FlutterJSBridge receiveMessage]: $jsonData');
    final JSBridgeMessage message = JSBridgeMessage.fromJson(jsonData);
    if (message.isRequest) {
      _senderCall(message);
    }
    if (message.isResponse) {
      _receiverCallResponse(message);
    }
  }

  /// 发送jsbridge消息
  void _postMessage(Map<String, dynamic> jsonData) {
    _log('[FlutterJSBridge postMessage]: $jsonData');
    final String jsonString = jsonEncode(jsonData);
    final String encodeString = Uri.encodeFull(jsonString);
    final String scriptString =
        'WebViewJSBridge.onMessageReceived("$encodeString")';
    _messageExecutor?.call(scriptString);
  }

  /// 接收者调用方法
  Future<T> _receiverCall<T extends Object?>({
    required String handlerName,
    Object? data,
  }) {
    final JSBridgeMessage message = JSBridgeMessage.request(
      action: handlerName,
      data: data,
    );

    final Completer<T> completer = Completer<T>();
    _completers[message.id] = completer;

    _postMessage(message.toJson());

    return completer.future;
  }

  /// 接收者调用方法的回调
  void _receiverCallResponse(JSBridgeMessage message) {
    if (!_completers.containsKey(message.id)) {
      throw Exception(
          "[handler id: ${message.id} - handler name: ${message.action}] can't find!!!");
    }
    final Completer<Object?> completer = _completers[message.id]!;
    if (message.isResolved) {
      completer.complete(message.data);
    }
    if (message.isRejected) {
      completer.completeError(message.data ?? 'unknown error');
    }
    _completers.remove(message.id);
  }

  /// 发送者调用方法
  void _senderCall(JSBridgeMessage message) async {
    final String handlerName = message.action;
    if (_handlers.containsKey(handlerName)) {
      _handlers[handlerName]?.call(message.data).then((Object? data) {
        message = JSBridgeMessage.response(
          action: handlerName,
          data: data,
          id: message.id,
          resolved: true,
          rejected: false,
        );
        _senderCallResponse(message);
      }).catchError((_) {
        message = JSBridgeMessage.response(
          action: handlerName,
          data: _.toString(),
          id: message.id,
          resolved: false,
          rejected: true,
        );
        _senderCallResponse(message);
      });
    } else {
      message = JSBridgeMessage.response(
        action: handlerName,
        data: "handler name -> $handlerName can't find!!!",
        id: message.id,
        resolved: false,
        rejected: true,
      );
      _senderCallResponse(message);
    }
  }

  /// 发送者调用方法的回调
  void _senderCallResponse(JSBridgeMessage message) {
    _postMessage(message.toJson());
  }
}

/// 定义一个top-level（全局）变量，页面引入该文件后可以直接使用jsBridge
JSBridge jsBridge = JSBridge();
