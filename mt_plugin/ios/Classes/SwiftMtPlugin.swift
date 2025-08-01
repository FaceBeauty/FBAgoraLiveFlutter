import Flutter
import UIKit

public class SwiftMtPlugin: NSObject, FlutterPlugin{
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    
    let channel = FlutterMethodChannel(name: "mt_plugin", binaryMessenger: registrar.messenger())
    let instance = SwiftMtPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
  }
    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
    
}
