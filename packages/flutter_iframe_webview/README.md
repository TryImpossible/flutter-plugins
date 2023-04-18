一个运行在`Flutter Web`上的`WebView`组件，它是基于 [webview_flutter_web](https://pub.flutter-io.cn/packages/webview_flutter_web) 插件修改的，实现了`PlatformWebViewController`抽象类的所有方法，抹平了所有方法在全平台的调用异常，额外针对部分方法实现了相应的功能。

## 功能
此插件主要针对如何在`flutter web`与`web`中通信交互提供了一种解决方案，因为该插件是基于`iframe`模拟了一个`webview`，受制于浏览器的同源策略，不同域之间通信是会出现跨域问题的，最好的解决方式是通过`postMessage`去实现通信。此外，借助于 [flutter_jsbridge_sdk](https://pub.flutter-io.cn/packages/flutter_jsbridge_sdk) 插件，我们制定了统一的规范在`flutter web`与`web`进行通信。

| 方法                            | 是否实现 | 说明                          |
|-------------------------------|------|-----------------------------|
| loadFile                      | 否    | 平台不支持                       |
| loadFlutterAsset              | 否    | 平台不支持                       |
| loadHtmlString                | 是    ||
| loadRequest                   | 是    ||
| currentUrl                    | 是    ||
| canGoBack                     | 否    | 平台不支持                       |
| canGoForward                  | 否    | 平台不支持                       |
| goBack                        | 是    ||
| reload                        | 是    ||
| clearCache                    | 是    ||
| clearLocalStorage             | 是    |
| setPlatformNavigationDelegate | 是    | 部分实现（仅`onPageFinished`方法）   |
| runJavaScript                 | 是    ||
| runJavaScriptReturningResult  | 是    ||
| addJavaScriptChannel          | 是    | 仅支持添加`jsBridge.channelName` |
| removeJavaScriptChannel       | 是    ||
| getTitle                      | 是    ||
| scrollTo                      | 是    ||
| scrollBy                      | 是    ||
| getScrollPosition             | 是    ||
| enableZoom                    | 否    | 平台不支持                       |
| setBackgroundColor            | 是    ||
| setJavaScriptMode             | 是    ||
| setUserAgent                  | 否    | 平台不支持                       |


## 开始

在工程的`pubspec.yaml`文件中添加`flutter_jsbridge_sdk`插件

```yaml
dependencies:
  flutter_iframe_webview: ^1.0.2
  flutter_jsbridge_sdk: ^1.0.1
```

```dart
import 'package:flutter_iframe_webview/webview_flutter_web.dart';
import 'package:flutter_jsbridge_sdk/flutter_jsbridge_sdk.dart';
```

## Flutter配置
### WebViewController
```
late final PlatformWebViewController platform;
if (WebViewPlatform.instance is WebWebViewPlatform) {
  platform = WebWebViewController(WebWebViewControllerCreationParams());
} else {
  platform = PlatformWebViewController(
  const PlatformWebViewControllerCreationParams());
}
final WebViewController controller = WebViewController.fromPlatform(platform);
controller
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            debugPrint('WebView is loading (progress : $progress%)');
          },
          onPageStarted: (String url) {
            debugPrint('Page started loading: $url');
          },
          onPageFinished: (String url) {
            debugPrint('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('''
Page resource error:
  code: ${error.errorCode}
  description: ${error.description}
  errorType: ${error.errorType}
  isForMainFrame: ${error.isForMainFrame}
          ''');
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://www.youtube.com/')) {
              debugPrint('blocking navigation to ${request.url}');
              return NavigationDecision.prevent;
            }
            debugPrint('allowing navigation to ${request.url}');
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        jsBridge.channelName,
        onMessageReceived: (JavaScriptMessage message) {
          jsBridge.onMessageReceived(message.message);
        },
      )
      ..addJavaScriptChannel(
        'Toaster',
        onMessageReceived: (JavaScriptMessage message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        },
      )
      ..loadRequest(Uri.parse('http://192.168.101.143:5500/page1.html'))
```

### JavaScriptChannel
```
 controller.addJavaScriptChannel(
    jsBridge.channelName,
    onMessageReceived: (JavaScriptMessage message) {
      jsBridge.onMessageReceived(message.message);
    },
  )
```
### jsBridge
```
jsBridge.init(
  messageExecutor: (controller.platform as WebWebViewController).postMessage,
  debug: true,
);
```

## JS配置
为了正常通信，`web`端还需引入`javascript-jsbridge-sdk`库，
具体参考 [javascript-jsbridge-sdk](https://github.com/TryImpossible/javascript-jsbridge-sdk)

## 如何通信
关于如何在`flutter_web`与`web`中通信，请参考 [flutter_jsbridge_sdk](https://pub.flutter-io.cn/packages/flutter_jsbridge_sdk)