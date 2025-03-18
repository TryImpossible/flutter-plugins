
import 'flutter_outline_vpn_platform_interface.dart';

class FlutterOutlineVpn {
  Future<String?> getPlatformVersion() {
    return FlutterOutlineVpnPlatform.instance.getPlatformVersion();
  }
}
