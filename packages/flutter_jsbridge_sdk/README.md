## 介绍

一个轻量级的 jsbridge，用于在 WebView 中的 flutter 和 javascript 之间发送消息。

## 功能

- 不依赖于webview_flutter
- 支持查看消息日志（debug模式）
- 支持注册方法
- 支持取消注册方法
- 支持Flutter和Javascript之间方法互相调用，传递参数、接收返回结果

<img src="https://github.com/TryImpossible/flutter_jsbridge_sdk/raw/main/Simulator_Screen_Shot.png" width = 30% height = 30% />

## 开始

在工程的`pubspec.yaml`文件中添加`flutter_jsbridge_sdk`插件

```yaml
dependencies:
  flutter_jsbridge_sdk: ^1.0.1
```

## Flutter用法

### 初始化配置

```text
 WebView(
  onWebViewCreated: (WebViewController controller) {
    // 配置jsBridge
    jsBridge.init(
      messageRunner: controller.runJavascript,
      debug: true,
    );
  },
  initialUrl: _initialUrl!,
  javascriptMode: JavascriptMode.unrestricted,
  javascriptChannels: <JavascriptChannel>{
    // 配置JavascriptChannel
    JavascriptChannel(
      name: jsBridge.channelName,
      onMessageReceived: (JavascriptMessage message) {
        jsBridge.onMessageReceived(message.message);
      },
    ),
  },
  navigationDelegate: (NavigationRequest navigation) {
    return NavigationDecision.navigate;
  },
)
```

#### 配置jsBridge

```text
jsBridge.init(
  messageRunner: controller.runJavascript,
  debug: true,
);
```

| 参数            | 说明                                                     | 默认值和类型                  | 必传  |
|---------------|--------------------------------------------------------|-------------------------|-----|
| debug         | 调试模式                                                   | false(Boolean)          | 否   |
| messageRunner | 提供flutter执行js代码的能力，使用WebViewController的runJavascript即可 | (JSBridgeMessageRunner) | 是   |

#### 配置JavascriptChannel

```text
JavascriptChannel(
  name: jsBridge.channelName, // 必须使用jsBridge.channelName
  onMessageReceived: (JavascriptMessage message) {
    jsBridge.onMessageReceived(message.message);
  },
),
```

### 注册方法

```text
jsBridge.registerHandler<String>('FlutterEcho', (Object? data) async {
  // return Future<String>.value('success response from flutter');
  // return 'success response from flutter';
  return Future.error('fail response from flutter');
  // throw Exception('fail response from flutter');
});
```

| 参数          | 说明                                                                                                            | 默认值和类型            | 必传  |
|-------------|---------------------------------------------------------------------------------------------------------------|-------------------|-----|
| handlerName | 注册的方法名称                                                                                                       | (String)          | 是   |
| handler     | 注册的方法实现，返回Future<br/>data:发送过来的数据<br/>Future.value:flutter端业务处理成功时通知js端<br/>Future.error:flutter端业务处理失败时通知js端 | (JSBridgeHandler) | 是   |

### 取消注册方法

```text
  jsBridge.unregisterHandler('FlutterEcho');
```

| 参数          | 说明      | 默认值和类型 | 必传  |
|-------------|---------|--------|-----|
| handlerName | 注册的方法名称 | (void) | 是   |

### 调用方法

```text
 try {
  final String data = await jsBridge.callHandler<String>(
    'JSEcho',
    data: 'request from flutter',
  );
  _log('[call handler] success response: $data');
 } catch (err) {
  _log('[call handler] fail response: $err');
 }
```

| 参数          | 说明                                                                       | 默认值和类型    | 必传  |
|-------------|--------------------------------------------------------------------------|-----------|-----|
| handlerName | 调用的方法名称                                                                  | (String)  | 是   |
| data        | 参数<br/>data:发送过来的数据                                                      | (Object?) | 否   |
| return      | 返回Future对象<br/>Future.value:js端业务处理成功时的回调<br/>Future.error:js端业务处理失败时的回调 | (Future)  | 是   |

## JS用法

js端的使用基本跟flutter保持一致，具体参考 [javascript-jsbridge-sdk](https://github.com/TryImpossible/javascript-jsbridge-sdk)