//
//  PlatformTextView.swift
//  Runner
//
//  Created by N17 on 2021/6/29.
//

import Foundation
import Flutter
class PlatformTextView: NSObject,FlutterPlatformView {
    private var _view: IOSFlutterView

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        _view = IOSFlutterView.shareManager()
        _view.frame = frame
        super.init()
        // 你可以根据 args 初始化 _view，或做其他操作
    }

//    override init() {
//        NSLog("测试:准备ok!")
//        
//    }
    
    func view() -> UIView {
        return _view
    }
//    init(_ frame: CGRect,viewID: Int64,args :Any?) {
//        self.frame = frame
//        self.viewId = viewID
//        if(args is NSDictionary){
//            let dict = args as! NSDictionary
//            self.text = dict.value(forKey: "text") as! String
//        }
//    }
//
   
//    FlutterMethodChannel* channel = [FlutterMethodChannel methodChannelWithName:@"mt_plugin" binaryMessenger:[registrar messenger]];
    
//    func view() -> UIView {
//        
//        let iosView = IOSFlutterView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
//        return iosView
//        
//    }
    
}
