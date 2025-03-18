import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_outline_vpn_platform_interface.dart';

/// An implementation of [FlutterOutlineVpnPlatform] that uses method channels.
class MethodChannelFlutterOutlineVpn extends FlutterOutlineVpnPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_outline_vpn');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
