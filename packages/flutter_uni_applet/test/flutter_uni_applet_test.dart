import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_uni_applet/flutter_uni_applet.dart';
import 'package:flutter_uni_applet/flutter_uni_applet_platform_interface.dart';
import 'package:flutter_uni_applet/flutter_uni_applet_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterUniAppletPlatform
    with MockPlatformInterfaceMixin
    implements FlutterUniAppletPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterUniAppletPlatform initialPlatform = FlutterUniAppletPlatform.instance;

  test('$MethodChannelFlutterUniApplet is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterUniApplet>());
  });

  test('getPlatformVersion', () async {
    FlutterUniApplet flutterUniAppletPlugin = FlutterUniApplet();
    MockFlutterUniAppletPlatform fakePlatform = MockFlutterUniAppletPlatform();
    FlutterUniAppletPlatform.instance = fakePlatform;

    expect(await flutterUniAppletPlugin.getPlatformVersion(), '42');
  });
}
