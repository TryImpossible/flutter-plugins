import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_st_ble_sensor/flutter_st_ble_sensor_method_channel.dart';

void main() {
  MethodChannelFlutterStBleSensor platform = MethodChannelFlutterStBleSensor();
  const MethodChannel channel = MethodChannel('flutter_st_ble_sensor');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
