import 'flutter_uni_applet_platform_interface.dart';

class FlutterUniApplet {
  Future<String?> getPlatformVersion() {
    return FlutterUniAppletPlatform.instance.getPlatformVersion();
  }

  Future<bool?> openApplet() {
    return FlutterUniAppletPlatform.instance.openApplet();
  }
}
