import 'flutter_st_ble_sensor_platform_interface.dart';

class FlutterStBleSensor {
  Future<String?> getPlatformVersion() {
    return FlutterStBleSensorPlatform.instance.getPlatformVersion();
  }

  Future<void> startScan() {
    return FlutterStBleSensorPlatform.instance.startScan();
  }
}
