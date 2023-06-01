import Flutter
import UIKit

public class FlutterStBleSensorPlugin: NSObject, FlutterPlugin {
  private static var delegate:StBleSensorDelegate!
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_st_ble_sensor", binaryMessenger: registrar.messenger())
    let instance = FlutterStBleSensorPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    delegate = StBleSensorDelegate()
  }
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "getPlatformVersion" {
      result("iOS " + UIDevice.current.systemVersion)
    } else {
      FlutterStBleSensorPlugin.delegate.handle(call, result: result)
    }
  }
}

