//
//  Extensions.swift
//  WaterfallLayoutDemo
//
//  Created by 周健平 on 2023/6/4.
//

import UIKit

extension UIApplication {
    /// Main Window
    @objc static var fa_window: UIWindow? {
        shared.jp_window
    }
    
    /// Key Window
    @objc static var jp_keyWindow: UIWindow? {
        shared.jp_keyWindow
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

extension EnvUpdateOptions {
    var jp_log: String {
        var str = ""
        if self.contains(.bounds) {
            str += "sceneBounds_变了，"
        } else {
            str += "sceneBounds_没变，"
        }
        if self.contains(.safeArea) {
            str += "safeAreaInsets_变了，"
        } else {
            str += "safeAreaInsets_没变，"
        }
        if self.contains(.horSizeClass) {
            str += "horSizeClass_变了，"
        } else {
            str += "horSizeClass_没变，"
        }
        if self.contains(.verSizeClass) {
            str += "verSizeClass_变了。"
        } else {
            str += "verSizeClass_没变。"
        }
        return str
    }
}

extension EnvDisplayMode {
    var jp_log: String {
        switch self {
        case .innerLandscapeFull:
            return "innerLandscapeFull_内屏横屏铺满"
        case .innerSplitLeft:
            return "innerSplitLeft_内屏分屏左边"
        case .innerSplitRight:
            return "innerSplitRight_内屏分屏右边"
        case .innerPortraitFull:
            return "innerPortraitFull_内屏竖屏铺满"
        default:
            return "outerPortrait_外屏竖向"
        }
    }
    
    var isOuter: Bool {
        switch self {
        case .outerPortrait:
            return true
        default:
            return false
        }
    }
    
    var isInner: Bool {
        switch self {
        case .outerPortrait:
            return false
        default:
            return true
        }
    }
    
    var isPortrait: Bool {
        switch self {
        case .outerPortrait, .innerPortraitFull:
            return true
        default:
            return false
        }
    }
    
    var isLandscape: Bool {
        switch self {
        case .innerLandscapeFull:
            return true
        default:
            return false
        }
    }
    
    var isSplit: Bool {
        switch self {
        case .innerSplitLeft, .innerSplitRight:
            return true
        default:
            return false
        }
    }
}

extension EnvHingeStatus {
    var jp_log: String {
        switch self {
        case .closed:
            return "closed_已闭合"
        case .partiallyOpen:
            return "partiallyOpen_对折中"
        case .fullyOpen:
            return "fullyOpen_全展开"
        default:
            return "unknown"
        }
    }
}

extension UIInterfaceOrientation {
    var jp_log: String {
        switch self {
        case .portrait:
            return "portrait"
        case .portraitUpsideDown:
            return "portraitUpsideDown"
        case .landscapeLeft:
            return "landscapeLeft"
        case .landscapeRight:
            return "landscapeRight"
        default:
            return "unknown"
        }
    }
}

extension UIUserInterfaceSizeClass {
    var jp_log: String {
        switch self {
        case .compact:
            return "compact_紧凑型_空间受限"
        case .regular:
            return "regular_常规型_空间充裕"
        default:
            return "unspecified"
        }
    }
}

@available(iOS 27.1, *)
extension UIVerticalBarEdge {
    var jp_log: String {
        switch self {
        case .leading:
            return "leading"
        case .trailing:
            return "trailing"
        default:
            return "unspecified"
        }
    }
}
