import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'flutter_st_ble_sensor_method_channel.dart';

abstract class FlutterStBleSensorPlatform extends PlatformInterface {
  /// Constructs a FlutterStBleSensorPlatform.
  FlutterStBleSensorPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutterStBleSensorPlatform _instance =
      MethodChannelFlutterStBleSensor();

  /// The default instance of [FlutterStBleSensorPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutterStBleSensor].
  static FlutterStBleSensorPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutterStBleSensorPlatform] when
  /// they register themselves.
  static set instance(FlutterStBleSensorPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> startScan() {
    throw UnimplementedError('startScan() has not been implemented.');
  }
}
