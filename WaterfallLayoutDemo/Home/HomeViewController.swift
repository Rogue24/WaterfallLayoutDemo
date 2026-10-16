//
//  HomeViewController.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit
import SnapKit

class HomeViewController: UIViewController {
    private var models: [WaterfallModel] = []
    
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
        collectionView.contentInsetAdjustmentBehavior = .scrollableAxes
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(WaterfallCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    private let segmentedControl = UISegmentedControl(items: ["增", "删", "改"])
//    private let segments = NavActionSegments()
    
    private weak var browseImgView: BrowseImageView? = nil
    
    private var isAppear: Bool = false
    
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
    
    private var colCount = 4
    private var contentInsets: UIEdgeInsets = .zero
    
    override func viewDidLoad() {
        super.viewDidLoad()
        resetLayoutAttributes()
        setupBase()
        setupItems()
        setupCollectionView()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
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
    
    private func animateUpdate(_ updateHandle: @escaping (_ collectionView: UICollectionView) -> ()) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
            self.collectionView.performBatchUpdates {
                updateHandle(self.collectionView)
            }
        }
    }
}

// MARK: - Setup
private extension HomeViewController {
    func setupBase() {
        view.backgroundColor = .systemBackground
        navigationItem.title = "WaterfallLayout_Demo"
        navigationItem.largeTitleDisplayMode = .automatic
    }
    
    func setupItems() {
        segmentedControl.selectedSegmentIndex = 0
        let segItem = UIBarButtonItem(customView: segmentedControl)
//        let segItem = UIBarButtonItem(customView: segments)
        navigationItem.rightBarButtonItem = segItem
        
        var items: [UIBarButtonItem] = []
        
        let flexibleSpace = UIBarButtonItem(
            barButtonSystemItem: .flexibleSpace,
            target: nil,
            action: nil
        )
        items.append(flexibleSpace)
        
        if !Env.isDuo {
            let colItem = UIBarButtonItem(
                image: UIImage(systemName: "list.number"),
                style: .plain,
                target: self,
                action: #selector(chooseCol)
            )
            items.append(colItem)
        }
        
        let reloadItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(reloadAll)
        )
        items.append(reloadItem)
        
        let addItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addArray)
        )
        items.append(addItem)
        
        toolbarItems = items
    }
    
    func setupCollectionView() {
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - Actions
private extension HomeViewController {
    @objc func chooseCol() {
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
    
    func browse(_ cell: WaterfallCell) {
        browseImgView = BrowseImageView.show(from: cell) { [weak self] model in
            guard let self else { return nil }
            for kCell in self.collectionView.visibleCells {
                guard let c = kCell as? WaterfallCell, c.model === model else { continue }
                return c
            }
            return nil
        } didHide: { [weak self] in
            self?.resetVisibleCells()
        }
    }
}

// MARK: - <UICollectionViewDataSource, UICollectionViewDelegate>
extension HomeViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        models.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! WaterfallCell
        cell.model = models[indexPath.item]
        // 长按预览
        cell.goBrowse = { [weak self] in
            self?.browse($0)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard WaterfallStore.isLoaded else { return }
        collectionView.setContentOffset(collectionView.contentOffset, animated: true)
        
        switch segmentedControl.selectedSegmentIndex {
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

// MARK: - <WaterfallLayoutDelegate>
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
private extension HomeViewController {
    func updateLayoutIfNeeded() {
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
        
        // 铰链变化，这里只对内屏横屏做处理
        guard displayMode == .innerLandscapeFull else { return }
        
        // 只对开放状态之间的切换（对折开<->全展开）做布局刷新
        guard (nowStatus == .partiallyOpen && (oldStatus == .fullyOpen || oldStatus == .unknown))
           || (oldStatus == .partiallyOpen && nowStatus == .fullyOpen)
        else { return }
        
        updateLayout(duration: duration)
    }
    
    func updateLayout(duration: TimeInterval) {
        resetLayoutAttributes()
        collectionView.collectionViewLayout.invalidateLayout()
        
        guard duration > 0 else {
            collectionView.layoutIfNeeded()
            DispatchQueue.main.async {
                self.resetVisibleCells()
            }
            return
        }
        
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 1,
            initialSpringVelocity: 0,
            options: .beginFromCurrentState
        ) {
            self.collectionView.layoutIfNeeded()
        } completion: { _ in
            self.resetVisibleCells()
        }
    }
}

// MARK: - 设置布局属性
private extension HomeViewController {
    func resetLayoutAttributes() {
        if Env.isDuo {
            colCount = Env.isHorRegular ? 4 : 3
        }
        
        var contentInsets = UIEdgeInsets(top: 5, left: 20, bottom: 5, right: 20)
        if Env.safeAreaInsets.right > 0 {
            contentInsets.right = Env.safeAreaInsets.right
        }
        if Env.displayMode == .innerLandscapeFull, Env.isHingeActive {
            // 横屏对折时，左右间距保持一致，让列表能居中对折
            contentInsets.left = contentInsets.right
        } else if Env.safeAreaInsets.left > 0 {
            contentInsets.left = Env.safeAreaInsets.left
        }
        self.contentInsets = contentInsets
    }
    
    func resetVisibleCells() {
        guard browseImgView != nil else { return }
        collectionView.indexPathsForVisibleItems.forEach {
            guard let cell = collectionView.cellForItem(at: $0) as? WaterfallCell else { return }
            cell.isHidden = models[$0.item].isBrowsing
        }
    }
}
