import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_outline_vpn_method_channel.dart';

abstract class FlutterOutlineVpnPlatform extends PlatformInterface {
  /// Constructs a FlutterOutlineVpnPlatform.
  FlutterOutlineVpnPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterOutlineVpnPlatform _instance = MethodChannelFlutterOutlineVpn();

  /// The default instance of [FlutterOutlineVpnPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterOutlineVpn].
  static FlutterOutlineVpnPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterOutlineVpnPlatform] when
  /// they register themselves.
  static set instance(FlutterOutlineVpnPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
