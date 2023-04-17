import 'package:flutter_iframe_webview/webview_flutter_web.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

import 'abstract_webview_controller_delegate.dart';

class WebViewControllerDelegate extends AbstractWebViewControllerDelegate {
  WebViewControllerDelegate() {
    late final PlatformWebViewController platform;
    if (WebViewPlatform.instance is WebWebViewPlatform) {
      platform = WebWebViewController(WebWebViewControllerCreationParams());
    } else {
      platform = PlatformWebViewController(
          const PlatformWebViewControllerCreationParams());
    }
    delegateController = WebViewController.fromPlatform(platform);
  }

  @override
  Future<void> Function(String javascriptString) get messageExecutor =>
      (delegateController.platform as WebWebViewController).postMessage;
}
