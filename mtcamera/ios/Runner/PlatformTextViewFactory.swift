//
//  PlatformTextViewFactory.swift
//  Runner
//
//  Created by N17 on 2021/6/29.
//

import Foundation
import Flutter

class PlatformTextViewFactory: NSObject,FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    // 创建 FlutterPlatformView 实例
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return PlatformTextView(frame: frame, viewId: viewId, args: args, messenger: messenger)
    }
    
    
    
//    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
////        return PlatformTextView(frame,viewID: viewId,args: args)
//        
//        return PlatformTextView()
//    }
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
    
}
