import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_st_ble_sensor/flutter_st_ble_sensor.dart';
import 'package:flutter_st_ble_sensor/flutter_st_ble_sensor_platform_interface.dart';
import 'package:flutter_st_ble_sensor/flutter_st_ble_sensor_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterStBleSensorPlatform
    with MockPlatformInterfaceMixin
    implements FlutterStBleSensorPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> startScan() async {}
}

void main() {
  final FlutterStBleSensorPlatform initialPlatform =
      FlutterStBleSensorPlatform.instance;

  test('$MethodChannelFlutterStBleSensor is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterStBleSensor>());
  });

  test('getPlatformVersion', () async {
    FlutterStBleSensor flutterStBleSensorPlugin = FlutterStBleSensor();
    MockFlutterStBleSensorPlatform fakePlatform =
        MockFlutterStBleSensorPlatform();
    FlutterStBleSensorPlatform.instance = fakePlatform;

    expect(await flutterStBleSensorPlugin.getPlatformVersion(), '42');
  });
}
