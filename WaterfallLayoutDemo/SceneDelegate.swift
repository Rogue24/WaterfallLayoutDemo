//
//  SceneDelegate.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = MainWindow(windowScene: windowScene)
        self.window = window
        
        Env.setup(window)
        
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            // 同步给`AppDelegate.window` 👉🏻 统一全局主窗口获取处
            appDelegate.window = window
        }
        
        let homeVC = HomeViewController()
//        window.rootViewController = homeVC
        
        let navCtr = UINavigationController(rootViewController: homeVC)
        window.rootViewController = navCtr
        
        window.makeKeyAndVisible()
    }
    
    @available(iOS 26.0, *)
    func windowScene(
        _ windowScene: UIWindowScene,
        didUpdateEffectiveGeometry previousEffectiveGeometry: UIWindowScene.Geometry
    ) {
        // previousEffectiveGeometry：旧场地
        // windowScene.effectiveGeometry：新场地
        
        Self.log_1(windowScene)
        
        if windowScene.effectiveGeometry.isInteractivelyResizing {
            Self.log_2(windowScene)
            Self.log_3()
            return // 拖拽中尺寸会不断变化
        }
        
        // 此时的window还没真正的变化，需要下一轮Runloop才会同步最新的尺寸和安全区域
        DispatchQueue.main.async {
            Self.log_2(windowScene)
            Env.resetIfNeeded(windowScene)
            Self.log_3()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//            let rectOnScreen = windowScene.effectiveGeometry.coordinateSpace.convert(windowScene.effectiveGeometry.coordinateSpace.bounds, to: windowScene.screen.coordinateSpace)
//            print("jp_log rectOnScreen222222: \(rectOnScreen)")
//        }
    }
}









@available(iOS 26.0, *)
private extension SceneDelegate {
    static func log_1(_ windowScene: UIWindowScene) {
//        let geometry = windowScene.effectiveGeometry
//        let trait = windowScene.traitCollection
//        
//        let isResizing = geometry.isInteractivelyResizing // 是否正在拖拽窗口
//        print("jp_log isResizing: \(isResizing) --- \(lookTime())")
//        
//        let orientation = geometry.interfaceOrientation
//        print("jp_log orientation: \(orientation.jp_log)")
//        
//        let isOrientationLocked = geometry.isInterfaceOrientationLocked
//        print("jp_log isOrientationLocked: \(isOrientationLocked)")
//        
//        let displayScale = trait.displayScale
//        print("jp_log displayScale: \(displayScale)")
//        
//        let horSizeClass = trait.horizontalSizeClass
//        print("jp_log horizontalSizeClass: \(horSizeClass.jp_log)")
//        
//        let verSizeClass = trait.verticalSizeClass
//        print("jp_log verticalSizeClass: \(verSizeClass.jp_log)")
//        
//        if #available(iOS 27.1, *) {
//            let verBarEdge = trait.verticalBarEdge
//            print("jp_log verticalBarEdge: \(verBarEdge.jp_log)")
//        }
//        
//        let sceneBounds = geometry.coordinateSpace.bounds
//        print("jp_log scene.bounds: \(sceneBounds)")
//        
//        let screenBounds = windowScene.screen.coordinateSpace.bounds
//        print("jp_log screen.bounds: \(screenBounds)")
//        
//        let rectOnScreen = geometry.coordinateSpace.convert(sceneBounds, to: windowScene.screen.coordinateSpace)
//        print("jp_log rectOnScreen: \(rectOnScreen)")
    }
    
    static func log_2(_ windowScene: UIWindowScene) {
//        let mainBounds = UIScreen.main.bounds
//        print("jp_log UIScreen.main.bounds: \(mainBounds)")
//        
//        let statusBarFrame = windowScene.statusBarManager?.statusBarFrame ?? .zero
//        print("jp_log statusBarFrame: \(statusBarFrame)")
//        
//        if let window = windowScene.windows.first {
////            print("jp_log windows.first == self.window: \(window == self.window)") // true
////            print("jp_log windows.first == windowScene.keyWindow: \(window == windowScene.keyWindow)") // true
////            print("jp_log windows.first.windowScene == windowScene: \(window.windowScene == windowScene)") // true
//            print("jp_log window.bounds: \(window.bounds)")
//            print("jp_log window.safeAreaInsets: \(window.safeAreaInsets)")
//            if #available(iOS 27.1, *) {
//                if let hinge = window.reservedRegions(kind: .division, options: .includeInactive).first {
//                    print("jp_log 铰链 hinge: \(hinge.isActive), \(hinge.frame)")
//                    if hinge.frame.minX > window.bounds.midX {
//                        print("jp_log 铰链在App的右边，所以App在左半屏")
//                    } else if hinge.frame.maxX < window.bounds.midX {
//                        print("jp_log 铰链在App的左边，所以App在右半屏")
//                    } else {
//                        print("jp_log 铰链在App的中间，所以App满屏展示ing")
//                    }
//                } else {
//                    print("jp_log 找不着铰链")
//                }
//            }
//        }
    }
    
    static func log_3() {
//        print("jp_log displayMode: \(Env.displayMode.jp_log)")
//        print("jp_log hingeStatus: \(Env.hingeStatus.jp_log)")
//        print("jp_log hingeAngle: \(Env.hingeAngle)")
//        print("jp_log ------------------------------- \(lookTime())")
    }
}
