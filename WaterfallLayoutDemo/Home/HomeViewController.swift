//
//  HomeViewController.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    private lazy var collectionView: UICollectionView = {
        let waterfallLayout = WaterfallLayout()
        waterfallLayout.delegate = self
        waterfallLayout.asyncUpdateLayout(itemTotal: models.count) { [weak self] index, itemWidth in
            guard let self = self else { return 1 }
            let model = self.models[index]
            return itemWidth * (model.image.size.height / model.image.size.width)
        } completion: { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
                self.collectionView.performBatchUpdates {
                    self.collectionView.reloadSections(IndexSet(integer: 0))
                }
            }
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: waterfallLayout)
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WaterfallCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private let segments = NavActionSegments()
    
    private var colCount = 4
    
    private var models: [WaterfallModel] = []
    
    private var sceneSize: CGSize = Env.sceneSize
    private var safeAreaInsets: UIEdgeInsets = Env.safeAreaInsets
    
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
    
    private var contentInsets: UIEdgeInsets {
        var safeAreaInsets = self.safeAreaInsets
        safeAreaInsets.top = view.layoutMargins.top
        safeAreaInsets.bottom = view.layoutMargins.bottom
        if Env.displayMode == .innerLandscapeFull, Env.isHingeActive {
            // 横屏对折时，左右间距保持一致，让列表能居中对折
            safeAreaInsets.left = safeAreaInsets.right
        }
        safeAreaInsets.top += 5
        safeAreaInsets.left += 5
        safeAreaInsets.bottom += 5
        safeAreaInsets.right += 5
        return safeAreaInsets
    }
    
    private var isAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WaterfallLayout_Demo"
        view.backgroundColor = .systemBackground
        
        setupCollectionView()
        setupToolbar()
        
        WaterfallStore.loadDone = { [weak self] in
            guard let self = self else { return }
            self.models = WaterfallStore.models.shuffled()
            self.animateUpdate { collectionView in
                collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    deinit {
        WaterfallStore.loadDone = nil
    }
    
    private func animateUpdate(_ updateHandle: @escaping (_ collectionView: UICollectionView) -> ()) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
            self.collectionView.performBatchUpdates {
                updateHandle(self.collectionView)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        updateLayoutIfNeeded()
        isObservingSceneChanges = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isAppear else { return }
        isAppear = true
        WaterfallStore.loadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        isObservingSceneChanges = false
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("jp_log *** HomeVC ------- viewDidLayoutSubviews:")
//        print("jp_log *** HomeVC size: \(view.frame.size), safeAreaInsets: \(view.safeAreaInsets))")
//        print("jp_log *** HomeVC layoutMargins: \(view.layoutMargins)")
////        print("jp_log *** HomeVC directionalLayoutMargins: \(view.directionalLayoutMargins)")
////        print("jp_log *** HomeVC systemMinimumLayoutMargins: \(self.systemMinimumLayoutMargins))")
//        print("jp_log *** HomeVC ------- \(lookTime())")
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
//        print("jp_log *** HomeVC viewSafeAreaInsetsDidChange: \(view.frame.size), \(view.safeAreaInsets) --- \(lookTime())")
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: any UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
//        print("jp_log *** HomeVC transitionDuration ------- \(coordinator.transitionDuration)")
    }
}

private extension HomeViewController {
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func setupToolbar() {
        let colItem = UIBarButtonItem(
            image: UIImage(systemName: "list.number"),
            style: .plain,
            target: self,
            action: #selector(chooseColCount)
        )
        
        let reloadItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadAll)
        )
        
        let addItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addArray)
        )
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        
        let segItem = UIBarButtonItem(customView: segments)
        
        toolbarItems = [colItem, reloadItem, addItem, flexibleSpace, segItem]
    }
}

private extension HomeViewController {
    @objc func chooseColCount() {
        guard WaterfallStore.isLoaded else { return }
        let alertCtr = UIAlertController(title: "选择列数", message: nil, preferredStyle: .actionSheet)
        for i in 1...5 {
            alertCtr.addAction(UIAlertAction(title: "\(i)列", style: .default, handler: { _ in
                guard self.colCount != i else { return }
                self.colCount = i
                self.animateUpdate { collectionView in
                    collectionView.reloadSections(IndexSet(integer: 0))
                }
            }))
        }
        alertCtr.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alertCtr, animated: true)
    }
    
    @objc func reloadAll() {
        WaterfallStore.loadData()
    }
    
    @objc func addArray() {
        guard WaterfallStore.isLoaded else { return }
        
        let addModels = WaterfallStore.models.shuffled()
        var indexPaths: [IndexPath] = []
        for i in 0 ..< addModels.count {
            indexPaths.append(IndexPath(item: i + models.count, section: 0))
        }
        
        models += addModels
        animateUpdate { collectionView in
            collectionView.insertItems(at: indexPaths)
        }
    }
}

extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WaterfallCell
        cell.model = models[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard WaterfallStore.isLoaded else { return }
        
        collectionView.setContentOffset(collectionView.contentOffset, animated: true)
        
        switch segments.selectedIndex {
        // 增
        case 0:
            models.insert(WaterfallStore.models.randomElement()!, at: indexPath.item)
            animateUpdate { $0.insertItems(at: [indexPath]) }
        // 删
        case 1:
            models.remove(at: indexPath.item)
            animateUpdate { $0.deleteItems(at: [indexPath]) }
        // 改
        case 2:
            models[indexPath.item] = WaterfallStore.models.randomElement()!
            animateUpdate { $0.reloadItems(at: [indexPath]) }
        default:
            break
        }
    }
}

extension HomeViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        let model = models[index]
        if model.cellSize.width != itemWidth {
            model.resetCellSize(for: itemWidth)
        }
        return model.cellSize.height
    }
    
    func colCountInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> Int {
        colCount
    }
    
    func colMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5
    }
    
    func rowMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5
    }
    
    func edgeInsetsInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> UIEdgeInsets {
        contentInsets
    }
}

// MARK: - Duo适配_监听场景、铰链状态变化的通知
private extension HomeViewController {
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
        guard let rawValue = notification.userInfo?["options"] as? UInt else { return }
        let options = EnvUpdateOptions(rawValue: rawValue)
        let duration = notification.userInfo?["transitionDuration"] as? TimeInterval ?? 0
        updateLayout(options: options, duration: duration)
    }
    
    /// 铰链状态发生变化的通知
    @objc func didReceiveEnvHingeStatusDidChange(notification: Notification) {
//        guard let userInfo = notification.userInfo,
//              let oldRawValue = userInfo["oldStatus"] as? Int,
//              let nowRawValue = userInfo["nowStatus"] as? Int,
//              let oldStatus = EnvHingeStatus(rawValue: oldRawValue),
//              let nowStatus = EnvHingeStatus(rawValue: nowRawValue)
//        else { return }
        guard Env.displayMode == .innerLandscapeFull else { return }
        updateLayout(options: .safeArea, duration: 0.3)
    }
}

// MARK: - Duo适配_更新界面布局（如果有变化）
private extension HomeViewController {
    private func updateLayoutIfNeeded() {
        var options: EnvUpdateOptions = []
        if sceneSize != Env.sceneSize {
            options.insert(.bounds)
        }
        if safeAreaInsets != Env.safeAreaInsets {
            options.insert(.safeArea)
        }
        updateLayout(options: options, duration: 0)
    }
    
    func updateLayout(options: EnvUpdateOptions, duration: TimeInterval) {
        guard !options.isEmpty else { return }
        sceneSize = Env.sceneSize
        safeAreaInsets = Env.safeAreaInsets
        
        guard duration > 0 else {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.layoutIfNeeded()
            return
        }
        
        UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0) {
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.layoutIfNeeded()
        }
    }
}

