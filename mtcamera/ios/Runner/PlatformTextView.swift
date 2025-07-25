//
//  PlatformTextView.swift
//  Runner
//
//  Created by N17 on 2021/6/29.
//

import UIKit
import Flutter

class PlatformTextView: NSObject, FlutterPlatformView {
    private var _view: IOSFlutterView

    init(frame: CGRect, viewId: Int64, args: Any?, messenger: FlutterBinaryMessenger) {
        _view = IOSFlutterView.shareManager()
        _view.frame = frame
        super.init()
        // 你可以根据 args 初始化 _view，或做其他操作
    }

    func view() -> UIView {
        return _view
    }
}
