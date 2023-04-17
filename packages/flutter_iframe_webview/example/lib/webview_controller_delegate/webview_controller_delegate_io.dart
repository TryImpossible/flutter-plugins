import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

import 'abstract_webview_controller_delegate.dart';

class WebViewControllerDelegate extends AbstractWebViewControllerDelegate {
  WebViewControllerDelegate() {
    late final PlatformWebViewController platform;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      platform = WebKitWebViewController(WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
        mediaTypesRequiringUserAction: const <PlaybackMediaTypes>{
          PlaybackMediaTypes.audio,
          PlaybackMediaTypes.video,
        },
      ));
    } else if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      platform =
          AndroidWebViewController(AndroidWebViewControllerCreationParams());
      AndroidWebViewController.enableDebugging(true);
      (platform as AndroidWebViewController)
          .setMediaPlaybackRequiresUserGesture(false);
    } else {
      platform = PlatformWebViewController(
          const PlatformWebViewControllerCreationParams());
    }
    delegateController = WebViewController.fromPlatform(platform);
  }

  @override
  Future<void> Function(String javascriptString) get messageExecutor =>
      delegateController.runJavaScript;
}
