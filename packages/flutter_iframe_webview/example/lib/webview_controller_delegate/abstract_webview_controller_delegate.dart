import 'dart:typed_data';
import 'dart:ui';

import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/src/platform_webview_controller.dart';

abstract class AbstractWebViewControllerDelegate implements WebViewController {
  late final WebViewController delegateController;

  Future<void> Function(String javascriptString) get messageExecutor;

  @override
  Future<void> addJavaScriptChannel(
    String name, {
    required void Function(JavaScriptMessage p1) onMessageReceived,
  }) {
    return delegateController.addJavaScriptChannel(
      name,
      onMessageReceived: onMessageReceived,
    );
  }

  @override
  Future<bool> canGoBack() {
    return delegateController.canGoBack();
  }

  @override
  Future<bool> canGoForward() {
    return delegateController.canGoForward();
  }

  @override
  Future<void> clearCache() {
    return delegateController.clearCache();
  }

  @override
  Future<void> clearLocalStorage() {
    return delegateController.clearLocalStorage();
  }

  @override
  Future<String?> currentUrl() {
    return delegateController.currentUrl();
  }

  @override
  Future<void> enableZoom(bool enabled) {
    return delegateController.enableZoom(enabled);
  }

  @override
  Future<Offset> getScrollPosition() {
    return delegateController.getScrollPosition();
  }

  @override
  Future<String?> getTitle() {
    return delegateController.getTitle();
  }

  @override
  Future<void> goBack() {
    return delegateController.goBack();
  }

  @override
  Future<void> goForward() {
    return delegateController.goForward();
  }

  @override
  Future<void> loadFile(String absoluteFilePath) {
    return delegateController.loadFile(absoluteFilePath);
  }

  @override
  Future<void> loadFlutterAsset(String key) {
    return delegateController.loadFlutterAsset(key);
  }

  @override
  Future<void> loadHtmlString(String html, {String? baseUrl}) {
    return delegateController.loadHtmlString(html, baseUrl: baseUrl);
  }

  @override
  Future<void> loadRequest(
    Uri uri, {
    LoadRequestMethod method = LoadRequestMethod.get,
    Map<String, String> headers = const <String, String>{},
    Uint8List? body,
  }) {
    return delegateController.loadRequest(
      uri,
      method: method,
      headers: headers,
      body: body,
    );
  }

  @override
  PlatformWebViewController get platform => delegateController.platform;

  @override
  Future<void> reload() {
    return delegateController.reload();
  }

  @override
  Future<void> removeJavaScriptChannel(String javaScriptChannelName) {
    return delegateController.removeJavaScriptChannel(javaScriptChannelName);
  }

  @override
  Future<void> runJavaScript(String javaScript) {
    return delegateController.runJavaScript(javaScript);
  }

  @override
  Future<Object> runJavaScriptReturningResult(String javaScript) {
    return delegateController.runJavaScriptReturningResult(javaScript);
  }

  @override
  Future<void> scrollBy(int x, int y) {
    return delegateController.scrollBy(x, y);
  }

  @override
  Future<void> scrollTo(int x, int y) {
    return delegateController.scrollTo(x, y);
  }

  @override
  Future<void> setBackgroundColor(Color color) {
    return delegateController.setBackgroundColor(color);
  }

  @override
  Future<void> setJavaScriptMode(JavaScriptMode javaScriptMode) {
    return delegateController.setJavaScriptMode(javaScriptMode);
  }

  @override
  Future<void> setNavigationDelegate(NavigationDelegate delegate) {
    return delegateController.setNavigationDelegate(delegate);
  }

  @override
  Future<void> setUserAgent(String? userAgent) {
    return delegateController.setUserAgent(userAgent);
  }
}
