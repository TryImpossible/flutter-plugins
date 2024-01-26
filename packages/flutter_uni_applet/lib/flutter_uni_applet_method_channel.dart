import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_uni_applet_platform_interface.dart';

/// An implementation of [FlutterUniAppletPlatform] that uses method channels.
class MethodChannelFlutterUniApplet extends FlutterUniAppletPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_uni_applet');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<bool?> openApplet() async {
    final result = await methodChannel.invokeMethod<bool>('openApplet');
    return result;
  }
}
