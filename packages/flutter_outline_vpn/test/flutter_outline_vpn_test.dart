import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_outline_vpn/flutter_outline_vpn.dart';
import 'package:flutter_outline_vpn/flutter_outline_vpn_platform_interface.dart';
import 'package:flutter_outline_vpn/flutter_outline_vpn_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutterOutlineVpnPlatform
    with MockPlatformInterfaceMixin
    implements FlutterOutlineVpnPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutterOutlineVpnPlatform initialPlatform = FlutterOutlineVpnPlatform.instance;

  test('$MethodChannelFlutterOutlineVpn is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutterOutlineVpn>());
  });

  test('getPlatformVersion', () async {
    FlutterOutlineVpn flutterOutlineVpnPlugin = FlutterOutlineVpn();
    MockFlutterOutlineVpnPlatform fakePlatform = MockFlutterOutlineVpnPlatform();
    FlutterOutlineVpnPlatform.instance = fakePlatform;

    expect(await flutterOutlineVpnPlugin.getPlatformVersion(), '42');
  });
}
