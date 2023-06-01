import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'flutter_st_ble_sensor_platform_interface.dart';

/// An implementation of [FlutterStBleSensorPlatform] that uses method channels.
class MethodChannelFlutterStBleSensor extends FlutterStBleSensorPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('flutter_st_ble_sensor');

  @override
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> startScan() async {
    await methodChannel.invokeMethod<String>('startScan');
  }
}
