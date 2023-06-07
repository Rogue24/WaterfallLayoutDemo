//
//  ViewController.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    lazy var collectionView: UICollectionView = {
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
    
    var colCount = 4
    
    var models: [WaterfallModel] = []
    
    var isAppear: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WaterfallLayout_Demo"
        
        view.insertSubview(collectionView, at: 0)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        WaterfallStore.loadDone = { [weak self] in
            guard let self = self else { return }
            self.models = WaterfallStore.models.shuffled()
            self.animateUpdate { collectionView in
                collectionView.reloadSections(IndexSet(integer: 0))
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !isAppear else { return }
        isAppear = true
        WaterfallStore.loadData()
    }
    
    deinit {
        WaterfallStore.loadDone = nil
    }
}

extension ViewController {
    @IBAction func chooseColCount(_ sender: Any) {
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
    
    @IBAction func reloadAll(_ sender: Any) {
        WaterfallStore.loadData()
    }
    
    @IBAction func addArray(_ sender: Any) {
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

extension ViewController {
    func animateUpdate(_ updateHandle: @escaping (_ collectionView: UICollectionView) -> ()) {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
            self.collectionView.performBatchUpdates {
                updateHandle(self.collectionView)
            }
        }
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
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

extension ViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        let model = models[index]
        if model.cellSize.width != itemWidth {
            model.resetCellSize(for: itemWidth)
        }
        return model.cellSize.height
    }
    
    func colCountInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> Int { colCount }
    
    func colMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat { 5 }
    
    func rowMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat { 5 }
    
    func edgeInsetsInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> UIEdgeInsets {
        var safeAreaInsets: UIEdgeInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        safeAreaInsets.top += 44 + 5
        safeAreaInsets.left += 5
        safeAreaInsets.bottom += 49 + 5
        safeAreaInsets.right += 5
        return safeAreaInsets
    }
}
