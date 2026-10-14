//
//  Extensions.swift
//  WaterfallLayoutDemo
//
//  Created by 周健平 on 2023/6/4.
//

import UIKit

extension UIApplication {
    /// Main Window
    @objc static var jp_window: UIWindow? {
        shared.jp_window
    }
    
    /// Key Window
    @objc static var jp_keyWindow: UIWindow? {
        shared.jp_keyWindow
    }
    
    /// App状态
    /// - .active: 正在前台，且处于活跃状态（正在接收用户交互）
    /// - .inactive: 处于前台，但未接收交互（例如：处于多任务切换界面、有电话呼入、或处于前台过渡状态）
    /// - .background: 已经进入后台
    @objc static var jp_appState: UIApplication.State {
        shared.applicationState
    }
}

extension UIApplication {
    /// Main Window
    @objc var jp_window: UIWindow? {
        if let kDelegate = delegate as? AppDelegate, let kWindow = kDelegate.window {
            return kWindow
        }
        
        return jp_keyWindow
    }
    
    /// Key Window
    @objc var jp_keyWindow: UIWindow? {
        let kWindows: [UIWindow]
        
        let scenes = connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .filter { $0.activationState != .unattached }
        
        if #available(iOS 15.0, *) {
            if let kWindow = scenes.compactMap({ $0.keyWindow }).first {
                return kWindow
            }
        }
        
        kWindows = scenes.flatMap { $0.windows }
        
        if let kWindow = kWindows.first(where: { $0.isKeyWindow }) {
            return kWindow
        }
        
        // 实在没有`keyWindow`，返回正在展示的`window`兜底
        return kWindows.first { !$0.isHidden && $0.alpha > 0 }
    }
}

extension UIImage {
    static func girlImage(_ index: Int) -> UIImage {
        UIImage(contentsOfFile: Bundle.main.path(forResource: "girl_\(index)", ofType: "jpg")!)!
    }
    
    static var randomGirlImage: UIImage {
        girlImage(Int.random(in: 1...16))
    }
}

extension CATransaction {
    static func execute(_ action: () -> ()) {
        begin()
        setDisableActions(true)
        action()
        commit()
    }
}
