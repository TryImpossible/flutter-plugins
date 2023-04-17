import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_jsbridge_sdk/flutter_jsbridge_sdk.dart';
import 'package:local_assets_server/local_assets_server.dart';
import 'package:webview_flutter/webview_flutter.dart';
// #docregion platform_imports
// Import for Android features.
import 'package:webview_flutter_android/webview_flutter_android.dart';
// Import for iOS features.
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
// #enddocregion platform_imports

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _controller = ScrollController();
  late final WebViewController _webViewController;
  String _logString = '';

  void _initLocalAssetsServer() {
    final LocalAssetsServer server = LocalAssetsServer(
      address: InternetAddress.loopbackIPv4,
      assetsBasePath: 'assets/',
      logger: const DebugLogger(),
    );
    server.serve().then((final InternetAddress value) {
      final String url =
          'http://${value.address}:${server.boundPort!}/example.html';
      _webViewController.loadRequest(Uri.parse(url));
    });
  }

  void _initWebViewController() {
    // #docregion platform_features
    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{},
      );
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewControllerCreationParams();
    }
    // else if (WebViewPlatform.instance is WebWebViewPlatform) {
    //   params = WebWebViewControllerCreationParams();
    // }
    else {
      params = const PlatformWebViewControllerCreationParams();
    }

    final WebViewController controller =
        WebViewController.fromPlatformCreationParams(params);
    // #enddocregion platform_features

    final NavigationDelegate navigationDelegate = NavigationDelegate(
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
    );
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFFFFFFF))
      ..setNavigationDelegate(navigationDelegate)
      ..addJavaScriptChannel(
        jsBridge.channelName,
        onMessageReceived: (JavaScriptMessage message) {
          jsBridge.onMessageReceived(message.message);
        },
      );

    // #docregion platform_features
    if (controller.platform is AndroidWebViewController) {
      AndroidWebViewController.enableDebugging(true);
      (controller.platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    }
    // #enddocregion platform_features

    _webViewController = controller;
  }

  void _initJSBridge() {
    jsBridge.init(
      messageExecutor: _webViewController.runJavaScript,
      debug: kDebugMode,
    );
  }

  @override
  void initState() {
    super.initState();
    _initWebViewController();
    _initLocalAssetsServer();
    _initJSBridge();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('jsbridge sdk'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            _buildWebView(),
            const SizedBox(height: 12.0),
            _buildButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Expanded(child: WebViewWidget(controller: _webViewController));
  }

  Widget _buildButton() {
    return Expanded(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                'Flutter',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('registerHandler'),
                  onPressed: () => _registerHandler(),
                ),
                ElevatedButton(
                  child: const Text('unregisterHandler'),
                  onPressed: () => _unregisterHandler(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                ElevatedButton(
                  child: const Text('callHandler'),
                  onPressed: () => _callHandler(),
                ),
                ElevatedButton(
                  child: const Text('callNotExistHandler'),
                  onPressed: () => _callNotExistHandler(),
                ),
              ],
            ),
            Container(
              height: 160,
              width: double.infinity,
              margin: const EdgeInsets.only(top: 12),
              color: const Color.fromRGBO(128, 128, 128, 0.1),
              child: SingleChildScrollView(
                controller: _controller,
                child: Text(_logString, style: const TextStyle(fontSize: 18)),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _log(String msg) {
    if (_logString.isNotEmpty) {
      msg = '$_logString\n$msg';
    }
    setState(() {
      _logString = msg;
    });
    Future.delayed(const Duration(milliseconds: 200), () {
      _controller.animateTo(
        _controller.position.maxScrollExtent,
        duration: kThemeAnimationDuration,
        curve: Curves.linear,
      );
    });
  }

  void _registerHandler() {
    _log('[register handler]');
    jsBridge.registerHandler<String>('FlutterEcho', (Object? data) async {
      // return Future<String>.value('success response from flutter');
      // return 'success response from flutter';
      return Future.error('fail response from flutter');
      // throw Exception('fail response from flutter');
    });
  }

  void _unregisterHandler() {
    _log('[unregister handler]');
    jsBridge.unregisterHandler('FlutterEcho');
  }

  Future<void> _callHandler() async {
    _log('[call handler] handlerName: JSEcho, data: request from javascript');
    try {
      final String data = await jsBridge.callHandler<String>(
        'JSEcho',
        data: 'request from flutter',
      );
      _log('[call handler] success response: $data');
    } catch (err) {
      _log('[call handler] fail response: $err');
    }
  }

  Future<void> _callNotExistHandler() async {
    _log(
        '[call handler] handlerName: JSEchoNotExist, data: request from javascript');
    try {
      final String data = await jsBridge.callHandler<String>(
        'JSEchoNotExist',
        data: 'request from flutter',
      );
      _log('[call handler] success response: $data');
    } catch (err) {
      _log('[call handler] fail response: $err');
    }
  }
}
