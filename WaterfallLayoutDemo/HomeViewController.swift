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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isAppear else { return }
        isAppear = true
        WaterfallStore.loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        print("jp_log *** HomeVC ------- viewDidLayoutSubviews:")
//        print("jp_log *** HomeVC size: \(view.frame.size), safeAreaInsets: \(view.safeAreaInsets))")
//        print("jp_log *** HomeVC layoutMargins: \(view.layoutMargins)")
//        print("jp_log *** HomeVC directionalLayoutMargins: \(view.directionalLayoutMargins)")
//        print("jp_log *** HomeVC systemMinimumLayoutMargins: \(self.systemMinimumLayoutMargins))")
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
        var safeAreaInsets = Env.safeAreaInsets
        safeAreaInsets.top += 5
        safeAreaInsets.left += 5
        safeAreaInsets.bottom += 5
        safeAreaInsets.right += 5
        return safeAreaInsets
    }
}





final private class NavActionSegments: UIView {
    private let titles = ["增", "删", "改"]
    private var buttons: [UIButton] = []
    
    private(set) var selectedIndex = 0
    var onSelect: ((Int) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        // 给内容留出边距，不自行绘制玻璃背景
        layoutMargins = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
        
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 0
        for (index, title) in titles.enumerated() {
            // .custom 不添加按钮自己的系统背景样式
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.backgroundColor = .clear
            button.addTarget(
                self,
                action: #selector(buttonTapped(_:)),
                for: .touchUpInside
            )
            stack.addArrangedSubview(button)
            buttons.append(button)
        }
        addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(self.layoutMarginsGuide)
        }
        
        updateAppearance(animated: false)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        CGSize(width: 132, height: 36)
    }
    
    @objc private func buttonTapped(_ sender: UIButton) {
        selectedIndex = sender.tag
        updateAppearance(animated: true)
        onSelect?(selectedIndex)
    }
    
    private func updateAppearance(animated: Bool) {
        for (index, button) in buttons.enumerated() {
            let selected = index == selectedIndex
            button.setTitleColor(
                selected ? .label : .secondaryLabel,
                for: .normal
            )
            button.titleLabel?.font = .systemFont(
                ofSize: 17,
                weight: selected ? .semibold : .regular
            )
            if animated {
                UIView.transition(with: button, duration: 0.12, options: .transitionCrossDissolve) {}
            }
        }
    }
}
