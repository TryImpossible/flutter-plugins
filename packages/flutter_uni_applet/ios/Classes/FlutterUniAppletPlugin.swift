import Flutter
import UIKit

public class FlutterUniAppletPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter_uni_applet", binaryMessenger: registrar.messenger())
    let instance = FlutterUniAppletPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    print("barry is testintg123");
    let options = NSMutableDictionary()
    options.setValue(NSNumber.init(value:true), forKey: "debug")
    DCUniMPSDKEngine.initSDKEnvironment(launchOptions: options as! [AnyHashable : Any]);
  }

  let APPID1 = "__UNI__11E9B73"
  
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getPlatformVersion":
      result("iOS " + UIDevice.current.systemVersion)
    case "openApplet":
      checkUniMPResoutce(appid: APPID1)
      let configuration = DCUniMPConfiguration.init()
      configuration.enableBackground = true
      configuration.openMode = DCUniMPOpenMode.push
      
      DCUniMPSDKEngine.openUniMP(APPID1, configuration: configuration) { instance, error in
          if instance != nil {
              print("小程序打开成功")
          } else {
              print(error as Any)
          }
      }

      result(true)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  func checkUniMPResoutce(appid: String) -> Void {
      let wgtPath = Bundle.main.path(forResource: appid, ofType: "wgt") ?? ""
      if DCUniMPSDKEngine.isExistsUniMP(appid) {
          let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
          let name = version["name"]!
          let code = version["code"]!
          print("小程序：\(appid) 资源已存在，版本信息：name:\(name) code:\(code)")
      } else {
          do {
              try DCUniMPSDKEngine.installUniMPResource(withAppid: appid, resourceFilePath: wgtPath, password: nil)
              let version = DCUniMPSDKEngine.getUniMPVersionInfo(withAppid: appid)!
              let name = version["code"]!
              let code = version["code"]!
              print("✅ 小程序：\(appid) 资源释放成功，版本信息：name:\(name) code:\(code)")
          } catch let err as NSError {
              print("❌ 小程序：\(appid) 资源释放失败:\(err)")
          }
      }
  }
  
  public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [AnyHashable : Any] = [:]) -> Bool {
    // Override point for customization after application launch.
    print("barry is testintg");

    let options = NSMutableDictionary.init(dictionary: launchOptions)
    options.setValue(NSNumber.init(value:true), forKey: "debug")
    DCUniMPSDKEngine.initSDKEnvironment(launchOptions: options as! [AnyHashable : Any]);
    return true
  }
  
  public func applicationDidBecomeActive(_ application: UIApplication) {
    DCUniMPSDKEngine.applicationDidBecomeActive(application)
  }
  
  public func applicationWillResignActive(_ application: UIApplication) {
    DCUniMPSDKEngine.applicationWillResignActive(application)
  }
  
  public func applicationDidEnterBackground(_ application: UIApplication) {
    DCUniMPSDKEngine.applicationDidEnterBackground(application)
  }
  
  public func applicationWillEnterForeground(_ application: UIApplication) {
    DCUniMPSDKEngine.applicationWillEnterForeground(application)
  }
  
  public func applicationWillTerminate(_ application: UIApplication) {
    DCUniMPSDKEngine.destory()
  }
  
  public func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    DCUniMPSDKEngine.application(application, open: url, options: options)
    return true
  }
  
  public func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
    // 通过通用链接唤起App
    DCUniMPSDKEngine.application(application, continue: userActivity)
    return true
  }
  
}
