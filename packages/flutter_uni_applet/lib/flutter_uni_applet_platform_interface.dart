import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_uni_applet_method_channel.dart';

abstract class FlutterUniAppletPlatform extends PlatformInterface {
  /// Constructs a FlutterUniAppletPlatform.
  FlutterUniAppletPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterUniAppletPlatform _instance = MethodChannelFlutterUniApplet();

  /// The default instance of [FlutterUniAppletPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterUniApplet].
  static FlutterUniAppletPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterUniAppletPlatform] when
  /// they register themselves.
  static set instance(FlutterUniAppletPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<bool?> openApplet() {
    throw UnimplementedError('openApplet() has not been implemented.');
  }
}
