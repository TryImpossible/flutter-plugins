// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:flutter/cupertino.dart';
import 'package:flutter_jsbridge_sdk/flutter_jsbridge_sdk.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'content_type.dart';
import 'http_request_factory.dart';
import 'shims/dart_ui.dart' as ui;

/// An implementation of [PlatformWebViewControllerCreationParams] using Flutter
/// for Web API.
@immutable
class WebWebViewControllerCreationParams
    extends PlatformWebViewControllerCreationParams {
  /// Creates a new [AndroidWebViewControllerCreationParams] instance.
  WebWebViewControllerCreationParams({
    @visibleForTesting this.httpRequestFactory = const HttpRequestFactory(),
  }) : super();

  /// Creates a [WebWebViewControllerCreationParams] instance based on [PlatformWebViewControllerCreationParams].
  WebWebViewControllerCreationParams.fromPlatformWebViewControllerCreationParams(
    // Recommended placeholder to prevent being broken by platform interface.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewControllerCreationParams params, {
    @visibleForTesting
        HttpRequestFactory httpRequestFactory = const HttpRequestFactory(),
  }) : this(httpRequestFactory: httpRequestFactory);

  static int _nextIFrameId = 0;

  /// Handles creating and sending URL requests.
  final HttpRequestFactory httpRequestFactory;

  /// The underlying element used as the WebView.
  @visibleForTesting
  final html.IFrameElement iFrame = html.IFrameElement()
    ..id = 'webView${_nextIFrameId++}'
    ..style.width = '100%'
    ..style.height = '100%'
    ..style.border = 'none';
}

/// An implementation of [PlatformWebViewController] using Flutter for Web API.
class WebWebViewController extends PlatformWebViewController {
  /// Constructs a [WebWebViewController].
  WebWebViewController(PlatformWebViewControllerCreationParams params)
      : super.implementation(params is WebWebViewControllerCreationParams
            ? params
            : WebWebViewControllerCreationParams
                .fromPlatformWebViewControllerCreationParams(params)) {
    _initialize();
  }

  WebWebViewControllerCreationParams get _webWebViewParams =>
      params as WebWebViewControllerCreationParams;

  bool _isLoaded = false;
  StreamSubscription<html.Event>? _iframeOnLoadSubscription;

  WebNavigationDelegate? _currentNavigationDelegate;

  static final Map<String, JavaScriptChannelParams> _javaScriptChannelParams =
      <String, JavaScriptChannelParams>{};

  static void _messageEventListener(html.Event event) {
    if (event is html.MessageEvent) {
      // final String decodeStr = Uri.decodeComponent(event.data);
      // final Map<String, dynamic> jsonData = jsonDecode(decodeStr);
      // debugPrint('native listen message: $jsonData');

      if (_javaScriptChannelParams.keys.contains(jsBridge.channelName)) {
        _javaScriptChannelParams[jsBridge.channelName]
            ?.onMessageReceived(JavaScriptMessage(message: event.data));
      }

      // for (final String channel in _javaScriptChannelParams.keys) {
      //   _javaScriptChannelParams[channel]
      //       ?.onMessageReceived(JavaScriptMessage(message: event.data));
      // }
    }
  }

  /// 返回的次数
  int _goBackCount = 0;

  void _initialize() {
    _setupIFrame();
    _addMessageEventListener();
  }

  void _dispose() {
    _removeMessageEventListener();
    _iframeOnLoadSubscription?.cancel();
    _iframeOnLoadSubscription = null;
  }

  void _setupIFrame() {
    html.IFrameElement iFrame = _webWebViewParams.iFrame;
    if (iFrame.sandbox != null) {
      final List<String> sandboxOptions = <String>[
        'allow-downloads',
        // 'allow-downloads-without-user-activation',
        'allow-forms',
        'allow-modals',
        'allow-orientation-lock',
        'allow-pointer-lock',
        'allow-popups',
        'allow-popups-to-escape-sandbox',
        'allow-presentation',
        'allow-same-origin',
        // 'allow-storage-access-by-user-activation',
        'allow-top-navigation',
        'allow-top-navigation-by-user-activation',
      ];
      sandboxOptions.forEach(iFrame.sandbox!.add);
    }

    final List<String> allowOptions = <String>[
      'accelerometer',
      'clipboard-write',
      'encrypted-media',
      'gyroscope',
      'picture-in-picture',
    ];
    iFrame.allow =
        allowOptions.reduce((String current, String next) => '$current; $next');

    iFrame.allowFullscreen = true;
    iFrame.allowPaymentRequest = true;

    // final html.MutationObserver observer = html.MutationObserver(
    //   (List mutations, html.MutationObserver observer) {
    //     html.window.console.info(mutations);
    //   },
    // );
    // observer.observe(iFrame, attributes: true);

    _iframeOnLoadSubscription?.cancel();
    _iframeOnLoadSubscription = iFrame.onLoad.listen((event) async {
      // iFrame.src = "about:blank";
      // html.window.console.info(event);
      final String url = (await currentUrl()) ?? '';
      if (!_isLoaded) {
        _isLoaded = true;
        _currentNavigationDelegate?._onPageStarted?.call(url);
      } else {
        _currentNavigationDelegate?._onPageFinished?.call(url);
      }
    });

    // const html.EventStreamProvider<html.Event>('load')
    //     .forElement(iFrame)
    //     .listen((html.Event event) {
    //   html.window.console.info(event);
    //   // iFrame.src = '';
    // });
  }

  void _addMessageEventListener() {
    html.window.addEventListener('message', _messageEventListener, true);
  }

  void _removeMessageEventListener() {
    html.window.removeEventListener('message', _messageEventListener, true);
  }

  Future<void> postMessage(String javaScript) async {
    // final RegExpMatch? match =
    // RegExp(r'WebViewJavascriptBridge.nativeCall\("(?<data>[\s\S]*)"\)')
    //     .firstMatch(javaScript);
    // if (match != null) {
    //   final String data = match.namedGroup('data') ?? '';
    //   _webWebViewParams.iFrame.contentWindow?.postMessage(data, '*');
    // }
    _webWebViewParams.iFrame.contentWindow?.postMessage(javaScript, '*');
  }

  @override
  Future<void> loadFile(
    String absoluteFilePath,
  ) async {}

  @override
  Future<void> loadFlutterAsset(
    String key,
  ) async {}

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) async {
    // ignore: unsafe_html
    _webWebViewParams.iFrame.src = Uri.dataFromString(
      html,
      mimeType: 'text/html',
      encoding: utf8,
    ).toString();
  }

  @override
  Future<void> loadRequest(LoadRequestParams params) async {
    if (!params.uri.hasScheme) {
      throw ArgumentError(
          'LoadRequestParams#uri is required to have a scheme.');
    }

    if (params.headers.isEmpty &&
        (params.body == null || params.body!.isEmpty) &&
        params.method == LoadRequestMethod.get) {
      // ignore: unsafe_html
      _webWebViewParams.iFrame.src = params.uri.toString();
    } else {
      await _updateIFrameFromXhr(params);
    }
  }

  /// Performs an AJAX request defined by [params].
  Future<void> _updateIFrameFromXhr(LoadRequestParams params) async {
    final html.HttpRequest httpReq =
        await _webWebViewParams.httpRequestFactory.request(
      params.uri.toString(),
      method: params.method.serialize(),
      requestHeaders: params.headers,
      sendData: params.body,
    );

    final String header =
        httpReq.getResponseHeader('content-type') ?? 'text/html';
    final ContentType contentType = ContentType.parse(header);
    final Encoding encoding = Encoding.getByName(contentType.charset) ?? utf8;

    // ignore: unsafe_html
    _webWebViewParams.iFrame.src = Uri.dataFromString(
      httpReq.responseText ?? '',
      mimeType: contentType.mimeType,
      encoding: encoding,
    ).toString();
  }

  @override
  Future<String?> currentUrl() async {
    if (jsBridge.hasReady) {
      return jsBridge.evalJavaScript<String?>('document.location.href');
    } else {
      return _webWebViewParams.iFrame.src;
    }
  }

  @override
  Future<bool> canGoBack() async {
    if (jsBridge.hasReady) {
      final int length =
          await jsBridge.evalJavaScript<int>('window.history.length');

      /// 为什么加2
      /// 默认进入的是个空白页面，记为1
      /// 栈顶页面得保留再退出iframe，记为1
      return length > (_goBackCount + 2);
    } else {
      return false;
    }
  }

  @override
  Future<bool> canGoForward() async {
    if (jsBridge.hasReady) {
      final int length =
          await jsBridge.evalJavaScript<int>('window.history.length');
      print('canGoForward: $length');
      return length > 0;
    } else {
      return false;
    }
  }

  @override
  Future<void> goBack() async {
    if (jsBridge.hasReady) {
      _goBackCount++;
      jsBridge.evalJavaScript('window.history.back()');
    }
  }

  @override
  Future<void> goForward() async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.history.forward()');
    }
  }

  @override
  Future<void> reload() async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.history.go(0)');
    }
  }

  @override
  Future<void> clearCache() async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.localStorage.clear()');
    }
  }

  @override
  Future<void> clearLocalStorage() async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.localStorage.clear()');
    }
  }

  @override
  Future<void> setPlatformNavigationDelegate(
    covariant WebNavigationDelegate handler,
  ) async {
    _currentNavigationDelegate = handler;
  }

  @override
  Future<void> runJavaScript(String javaScript) async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript(javaScript);
    }
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) async {
    if (jsBridge.hasReady) {
      return jsBridge.evalJavaScript<Object>(javaScript);
    }
    return Object();
  }

  @override
  Future<void> addJavaScriptChannel(
    JavaScriptChannelParams javaScriptChannelParams,
  ) async {
    _javaScriptChannelParams[javaScriptChannelParams.name] =
        javaScriptChannelParams;
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) async {
    _javaScriptChannelParams.remove(javaScriptChannelName);
  }

  @override
  Future<String?> getTitle() async {
    if (jsBridge.hasReady) {
      return jsBridge.evalJavaScript<String>('window.document.title');
    }
    return null;
  }

  @override
  Future<void> scrollTo(int x, int y) async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.scrollTo(x, y)');
    }
  }

  @override
  Future<void> scrollBy(int x, int y) async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.scrollBy(x, y)');
    }
  }

  @override
  Future<Offset> getScrollPosition() async {
    if (jsBridge.hasReady) {
      final int dx = await jsBridge.evalJavaScript<int>('window.scrollX');
      final int dy = await jsBridge.evalJavaScript<int>('window.scrollY');
      return Offset(dx.toDouble(), dy.toDouble());
    }
    return Offset.zero;
  }

  @override
  Future<void> enableZoom(bool enabled) async {}

  @override
  Future<void> setBackgroundColor(Color color) async {
    _webWebViewParams.iFrame.style.backgroundColor =
        'rgba(${color.red},${color.green},${color.blue},${color.alpha})';
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) async {
    if (javaScriptMode == JavaScriptMode.unrestricted) {
      _webWebViewParams.iFrame.sandbox?.add('allow-scripts');
    }
  }

  @override
  Future<void> setUserAgent(String? userAgent) async {
    if (jsBridge.hasReady) {
      await jsBridge.evalJavaScript('window.navigator.userAgent = $userAgent');
    }
  }
}

/// An implementation of [PlatformWebViewWidget] using Flutter the for Web API.
class WebWebViewWidget extends PlatformWebViewWidget {
  /// Constructs a [WebWebViewWidget].
  WebWebViewWidget(PlatformWebViewWidgetCreationParams params)
      : super.implementation(params) {
    final WebWebViewController controller =
        params.controller as WebWebViewController;
    ui.platformViewRegistry.registerViewFactory(
      controller._webWebViewParams.iFrame.id,
      (int viewId) =>
          html.DivElement()..append(controller._webWebViewParams.iFrame),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String id =
        (params.controller as WebWebViewController)._webWebViewParams.iFrame.id;
    return HtmlElementView(key: params.key, viewType: id);
  }
}

@immutable
class WebNavigationDelegateCreationParams
    extends PlatformNavigationDelegateCreationParams {
  /// Creates a new [WebNavigationDelegateCreationParams] instance.
  WebNavigationDelegateCreationParams._() : super();

  /// Creates a [WebNavigationDelegateCreationParams] instance based on [PlatformNavigationDelegateCreationParams].
  factory WebNavigationDelegateCreationParams.fromPlatformNavigationDelegateCreationParams(
      // Recommended placeholder to prevent being broken by platform interface.
      // ignore: avoid_unused_constructor_parameters
      PlatformNavigationDelegateCreationParams params) {
    return WebNavigationDelegateCreationParams._();
  }
}

class WebNavigationDelegate extends PlatformNavigationDelegate {
  /// Creates a new [AndroidNavigationDelegate].
  WebNavigationDelegate(PlatformNavigationDelegateCreationParams params)
      : super.implementation(params is WebNavigationDelegateCreationParams
            ? params
            : WebNavigationDelegateCreationParams
                .fromPlatformNavigationDelegateCreationParams(params));

  PageEventCallback? _onPageFinished;
  PageEventCallback? _onPageStarted;
  ProgressCallback? _onProgress;
  WebResourceErrorCallback? _onWebResourceError;
  NavigationRequestCallback? _onNavigationRequest;

  @override
  Future<void> setOnNavigationRequest(
    NavigationRequestCallback onNavigationRequest,
  ) async {
    _onNavigationRequest = onNavigationRequest;
  }

  @override
  Future<void> setOnPageStarted(
    PageEventCallback onPageStarted,
  ) async {
    _onPageStarted = onPageStarted;
  }

  @override
  Future<void> setOnPageFinished(
    PageEventCallback onPageFinished,
  ) async {
    _onPageFinished = onPageFinished;
  }

  @override
  Future<void> setOnProgress(
    ProgressCallback onProgress,
  ) async {
    _onProgress = onProgress;
  }

  @override
  Future<void> setOnWebResourceError(
    WebResourceErrorCallback onWebResourceError,
  ) async {
    _onWebResourceError = onWebResourceError;
  }

  @override
  Future<void> setOnUrlChange(UrlChangeCallback onUrlChange) async {}
}

@immutable
class WebWebViewCookieManagerCreationParams
    extends PlatformWebViewCookieManagerCreationParams {
  /// Creates a new [WebWebViewCookieManagerCreationParams] instance.
  const WebWebViewCookieManagerCreationParams._(
    // This parameter prevents breaking changes later.
    // ignore: avoid_unused_constructor_parameters
    PlatformWebViewCookieManagerCreationParams params,
  ) : super();

  /// Creates a [WebWebViewCookieManagerCreationParams] instance based on [PlatformWebViewCookieManagerCreationParams].
  factory WebWebViewCookieManagerCreationParams.fromPlatformWebViewCookieManagerCreationParams(
      PlatformWebViewCookieManagerCreationParams params) {
    return WebWebViewCookieManagerCreationParams._(params);
  }
}

/// Handles all cookie operations for the Web platform.
class WebWebViewCookieManager extends PlatformWebViewCookieManager {
  /// Creates a new [WebWebViewCookieManager].
  WebWebViewCookieManager(PlatformWebViewCookieManagerCreationParams params)
      : super.implementation(
          params is WebWebViewCookieManagerCreationParams
              ? params
              : WebWebViewCookieManagerCreationParams
                  .fromPlatformWebViewCookieManagerCreationParams(params),
        );

  @override
  Future<bool> clearCookies() async {
    return false;
  }

  @override
  Future<void> setCookie(WebViewCookie cookie) async {
    if (!_isValidPath(cookie.path)) {
      throw ArgumentError(
          'The path property for the provided cookie was not given a legal value.');
    }
    // return _cookieManager.setCookie(
    //   cookie.domain,
    //   '${Uri.encodeComponent(cookie.name)}=${Uri.encodeComponent(cookie.value)}; path=${cookie.path}',
    // );
  }

  bool _isValidPath(String path) {
    // Permitted ranges based on RFC6265bis: https://datatracker.ietf.org/doc/html/draft-ietf-httpbis-rfc6265bis-02#section-4.1.1
    for (final int char in path.codeUnits) {
      if ((char < 0x20 || char > 0x3A) && (char < 0x3C || char > 0x7E)) {
        return false;
      }
    }
    return true;
  }
}
