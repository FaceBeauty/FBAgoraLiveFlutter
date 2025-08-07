import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey:Any]?) -> Bool {
        GeneratedPluginRegistrant.register(with: self)
        
//        let factory = PlatformTextViewFactory()
//        
//        let registrar = self.registrar(forPlugin: "mt_plugin")
//        registrar?.register(factory, withId: "CameraView")
            
            let registrar = self.registrar(forPlugin: "mt_plugin")
            let factory = PlatformTextViewFactory(messenger: registrar!.messenger())
            registrar?.register(factory, withId: "CameraView")
            
            // MethodChannel 注册，监听 Flutter 消息
            let channel = FlutterMethodChannel(name: "beauty_plugin", binaryMessenger: registrar!.messenger())
            IOSFlutterView.shareManager().flutterChannel = channel
            channel.setMethodCallHandler { [weak self] call, result in
                guard let self = self else { return }
                
                if call.method == "startAgoraPush" {
                    IOSFlutterView.shareManager().startPushToAgora()
                    result(true)
                    
                } else if call.method == "stopAgoraPush" {
                    IOSFlutterView.shareManager().stopPushToAgora()
                    result(true)
                    
                }
                else if call.method == "setEngine" {
                    guard let appId = call.arguments as? String, !appId.isEmpty else {
                        result(FlutterError(code: "INVALID_ARGUMENT", message: "AppId不能为空", details: nil))
                        return
                    }
                    //                    let engine = AgoraRtcEngineKit.sharedEngine(withAppId: appId, delegate: nil)
                    //                    IOSFlutterView.shareManager().setAgoraEngine(engine)
                    //                    NSLog("✅ 成功设置 Flutter 初始化的 Agora 引擎: \(engine)")
                    result(true)
                } else {
                    result(FlutterMethodNotImplemented)
                }
            }
            
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
}
