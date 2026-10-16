//
//  BrowseImageView.swift
//  WaterfallLayoutDemo
//
//  Created by 周健平 on 2023/6/4.
//

import UIKit

class BrowseImageView: UIView {
    private let model: WaterfallModel
    private let getFromCell: ((_ model: WaterfallModel) -> WaterfallCell?)?
    private let didHide: (() -> Void)?
    
    private let blurView = JPBlurAnimationView(effectStyle: .systemThinMaterialDark, intensity: 0)
    private let imageView = UIImageView()
    
    private var imageFrame: CGRect = .zero
    
    private lazy var panGR = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
    private var isPaning = false
    private var isRecover = false
    private var currentCenterY: CGFloat = 0
    private var beginPosition: CGPoint = .zero
    
    private var displayMode = Env.displayMode
    private var hingeStatus = Env.hingeStatus
    
    private var isObservingSceneChanges: Bool = false {
        didSet {
            guard isObservingSceneChanges != oldValue else { return }
            if isObservingSceneChanges {
                startObservingSceneChanges()
            } else {
                stopObservingSceneChanges()
            }
        }
    }
    
    init(model: WaterfallModel, getFromCell: ((_ model: WaterfallModel) -> WaterfallCell?)?, didHide: (() -> Void)?) {
        self.model = model
        self.getFromCell = getFromCell
        self.didHide = didHide
        super.init(frame: Env.sceneBounds)
        clipsToBounds = false
        
        blurView.frame = self.bounds.insetBy(dx: -500, dy: -500)
        addSubview(blurView)
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapAction(_:))))
        imageView.addGestureRecognizer(panGR)
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Show / Hide
extension BrowseImageView {
    @discardableResult
    static func show(
        from cell: WaterfallCell,
        getFromCell: ((_ model: WaterfallModel) -> WaterfallCell?)?,
        didHide: (() -> Void)?
    ) -> BrowseImageView? {
        guard let window = cell.window, let model = cell.model else { return nil }
        let browseImageView = BrowseImageView(model: model, getFromCell: getFromCell, didHide: didHide)
        browseImageView.show(from: cell, on: window)
        return browseImageView
    }
    
    func show(from cell: WaterfallCell, on window: UIWindow) {
        imageView.image = cell.imgView.image
        imageView.layer.cornerRadius = cell.imgView.layer.cornerRadius
        imageView.layer.masksToBounds = imageView.layer.cornerRadius > 0
        imageView.frame = cell.convert(cell.bounds, to: window)
        imageView.isUserInteractionEnabled = false
        window.addSubview(self)
        
        let image = UIImage.girlImage(model.imageIndex)
        
        // next runloop to show
        DispatchQueue.main.async {
            self.model.isBrowsing = true
            cell.isHidden = true
            
            self.resetImageFrame()
            self.blurView.setIntensity(to: 1, duration: 0.5)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.imageView.layer.cornerRadius = 0
                self.imageView.frame = self.imageFrame
                self.imageView.image = image
            } completion: { _ in
                self.imageView.isUserInteractionEnabled = true
                self.updateLayoutIfNeeded()
                self.isObservingSceneChanges = true
            }
        }
    }
    
    func hide() {
        isObservingSceneChanges = false
        model.isBrowsing = false
        
        imageView.isUserInteractionEnabled = false
        blurView.setIntensity(to: 0, duration: 0.5)
        
        guard let cell = getFromCell?(model), let window else {
            self.didHide?()
            UIView.animate(withDuration: 0.2) {
                self.imageView.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
            return
        }
        
        let radius = cell.imgView.layer.cornerRadius
        let sourceFrame = cell.convert(cell.bounds, to: window)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0) {
            self.imageView.layer.cornerRadius = radius
            self.imageView.frame = sourceFrame
        } completion: { _ in
            cell.isHidden = false
            self.didHide?()
            UIView.animate(withDuration: 0.2) {
                self.imageView.alpha = 0
            } completion: { _ in
                self.removeFromSuperview()
            }
        }
    }
}

// MARK: - Gesture Handle
private extension BrowseImageView {
    @objc func tapAction(_ tapGR: UITapGestureRecognizer) {
        hide()
    }
    
    @objc func panAction(_ panGR: UIPanGestureRecognizer) {
        let translation = panGR.translation(in: imageView)
        panGR.setTranslation(.zero, in: imageView)
        
        switch panGR.state {
        case .began:
            isRecover = true
            isPaning = true
            
            let velocity = panGR.velocity(in: imageView)
            let isVerticalGesture = velocity.y > 0 && (abs(velocity.y) > abs(velocity.x))
            if !isVerticalGesture {
                isPaning = false
                return
            }
            
            currentCenterY = imageFrame.midY
            beginPosition = panGR.location(in: self)
            
            resetImageAnchorPoint(
                x: (beginPosition.x - imageFrame.origin.x) / imageFrame.width,
                y: (beginPosition.y - imageFrame.origin.y) / imageFrame.height
            )
            
        case .changed:
            guard isPaning else { return }
            
            currentCenterY += translation.y
            
            var blurIntensity: CGFloat = 1
            var sizeScale: CGFloat = 1
            
            let originCenterY = imageFrame.midY
            if currentCenterY > originCenterY {
                let currMargin = currentCenterY - originCenterY
                
                let diffMargin = originCenterY * 0.5
                isRecover = currMargin <= diffMargin
                
                var scale = currMargin / originCenterY
                if scale > 1 { scale = 1 }
                
                blurIntensity = 1 - scale
                
                // 1 - 0.4 = 0.6 为最大缩放比例
                sizeScale = (imageFrame.width * (1 - scale * 0.4)) / imageView.frame.width
            } else {
                isRecover = true
            }
            
            blurView.intensity = blurIntensity
            
            let transform = CATransform3DScale(imageView.layer.transform, sizeScale, sizeScale, 1)
            let position = panGR.location(in: self)
            CATransaction.execute {
                self.imageView.layer.transform = transform
                self.imageView.layer.position = position
            }
            
        case .ended, .cancelled, .failed:
            guard isPaning else {
                blurView.intensity = 1
                resetImageAnchorPoint(x: 0.5, y: 0.5)
                return
            }
            
            isPaning = false
            
            let velocity = panGR.velocity(in: imageView)
            let isHide = velocity.y > 1000 || !isRecover
            if isHide {
                hide()
                return
            }
            
            blurView.setIntensity(to: 1, duration: 0.3)
            
            UIView.animate(withDuration: 0.3) {
                self.imageView.layer.transform = CATransform3DIdentity
                self.imageView.layer.position = self.beginPosition
            } completion: { _ in
                self.resetImageAnchorPoint(x: 0.5, y: 0.5)
            }
            
        default:
            break
        }
    }
}

// MARK: - Duo适配_监听场景、铰链状态变化的通知
private extension BrowseImageView {
    func startObservingSceneChanges() {
        NotificationCenter.jp.addObserver(
            self,
            selector: #selector(didReceiveEnvSceneDidChange(notification:)),
            key: .EnvSceneDidChange
        )
        NotificationCenter.jp.addObserver(
            self,
            selector: #selector(didReceiveEnvHingeStatusDidChange(notification:)),
            key: .EnvHingeStatusDidChange
        )
    }
    
    func stopObservingSceneChanges() {
        NotificationCenter.jp.removeObserver(self, key: .EnvSceneDidChange)
        NotificationCenter.jp.removeObserver(self, key: .EnvHingeStatusDidChange)
    }
    
    /// 场景发生变化的通知（内外屏切换、内屏旋转、内屏全屏分屏切换、内屏左右分屏切换）
    @objc func didReceiveEnvSceneDidChange(notification: Notification) {
        displayMode = Env.displayMode
        hingeStatus = Env.hingeStatus
        let duration = notification.userInfo?["transitionDuration"] as? TimeInterval ?? 0
        updateLayout(duration: duration)
    }
    
    /// 铰链状态发生变化的通知
    @objc func didReceiveEnvHingeStatusDidChange(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let nowRawValue = userInfo["nowStatus"] as? Int,
              let nowStatus = EnvHingeStatus(rawValue: nowRawValue),
              let oldRawValue = userInfo["oldStatus"] as? Int,
              let oldStatus = EnvHingeStatus(rawValue: oldRawValue)
        else { return }
        updateLayoutIfNeeded(from: oldStatus, to: nowStatus, duration: 0.3)
    }
}

// MARK: - Duo适配_更新界面布局（如果有变化）
private extension BrowseImageView {
    private func updateLayoutIfNeeded() {
        guard displayMode != Env.displayMode else {
            updateLayoutIfNeeded(from: hingeStatus, to: Env.hingeStatus, duration: 0)
            return
        }
        
        displayMode = Env.displayMode
        hingeStatus = Env.hingeStatus
        updateLayout(duration: 0)
    }
    
    func updateLayoutIfNeeded(from oldStatus: EnvHingeStatus, to nowStatus: EnvHingeStatus, duration: TimeInterval) {
        guard hingeStatus != nowStatus else { return }
        hingeStatus = nowStatus
        
        // 铰链变化，外屏和内屏分屏时不做处理
        if displayMode.isOuter || displayMode.isSplit {
            return
        }
        
        // 只对开放状态之间的切换（对折开<->全展开）做布局刷新
        guard (nowStatus == .partiallyOpen && (oldStatus == .fullyOpen || oldStatus == .unknown))
           || (oldStatus == .partiallyOpen && nowStatus == .fullyOpen)
        else { return }
        
        updateLayout(duration: duration)
    }
    
    func updateLayout(duration: TimeInterval) {
        panGR.isEnabled = false
        resetImageFrame()
        
        guard duration > 0 else {
            frame = Env.sceneBounds
            blurView.frame = bounds.insetBy(dx: -500, dy: -500)
            imageView.layer.transform = CATransform3DIdentity
            imageView.frame = imageFrame
            resetImageAnchorPoint(x: 0.5, y: 0.5)
            panGR.isEnabled = true
            return
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState
        ) {
            self.frame = Env.sceneBounds
            self.blurView.frame = self.bounds.insetBy(dx: -500, dy: -500)
            self.imageView.layer.transform = CATransform3DIdentity
            self.imageView.frame = self.imageFrame
        } completion: { _ in
            self.resetImageAnchorPoint(x: 0.5, y: 0.5)
            self.panGR.isEnabled = true
        }
    }
}

// MARK: - 设置图片区域&锚点
private extension BrowseImageView {
    func resetImageFrame() {
        var safeAreaInsets = Env.safeAreaInsets
        if safeAreaInsets.top == 0 {
            safeAreaInsets.top = 24
        }
        if safeAreaInsets.bottom == 0 {
            safeAreaInsets.bottom = 24
        }
        if safeAreaInsets.left == 0 {
            safeAreaInsets.left = 20
        }
        if safeAreaInsets.right == 0 {
            safeAreaInsets.right = 20
        }
        
        if Env.isHingeActive {
            if Env.displayMode == .innerLandscapeFull {
                safeAreaInsets.left = Env.sceneWidth * 0.5 + 20
            }
            else if Env.displayMode == .innerPortraitFull {
                safeAreaInsets.bottom = Env.sceneHeight * 0.5 + 24
            }
        }
        
        let maxFrame = Env.sceneBounds.inset(by: safeAreaInsets)
        let cellSize = model.cellSize
        
        var size = CGSize(
            width: maxFrame.width,
            height: (cellSize.height / cellSize.width) * maxFrame.width
        )
        if size.height > maxFrame.height {
            size = CGSize(
                width: (cellSize.width / cellSize.height) * maxFrame.height,
                height: maxFrame.height
            )
        }
        
        let origin = CGPoint(
            x: maxFrame.origin.x + (maxFrame.width - size.width) * 0.5,
            y: maxFrame.origin.y + (maxFrame.height - size.height) * 0.5
        )
        
        imageFrame = CGRect(origin: origin, size: size)
    }
    
    func resetImageAnchorPoint(x: CGFloat, y: CGFloat) {
        let anchorPoint = CGPoint(x: x, y: y)
        let position = CGPoint(
            x: imageFrame.origin.x + imageFrame.width * x,
            y: imageFrame.origin.y + imageFrame.height * y
        )
        CATransaction.execute {
            self.imageView.layer.anchorPoint = anchorPoint
            self.imageView.layer.position = position
        }
    }
}
