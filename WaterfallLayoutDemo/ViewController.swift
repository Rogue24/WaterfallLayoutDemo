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
    
    var colCount = 4
    
    var girls: [Girl] = []
    
    lazy var collectionView: UICollectionView = {
        let waterfallLayout = WaterfallLayout()
        waterfallLayout.delegate = self
        
        waterfallLayout.asyncUpdateLayout(itemTotal: girls.count) { [weak self] index, itemWidth in
            guard let self = self else { return 1 }
            let girl = self.girls[index]
            return itemWidth / girl.whRatio
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
        collectionView.register(GirlCell.self, forCellWithReuseIdentifier: "cell")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "WaterfallLayout_Demo"
        
        view.insertSubview(collectionView, at: 0)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    @IBAction func chooseColCount(_ sender: Any) {
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
        DispatchQueue.global().async {
            let kGirls = Girl.fetchRandomList()
            DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                self.girls = kGirls
                self.animateUpdate { collectionView in
                    collectionView.reloadSections(IndexSet(integer: 0))
                }
            }
        }
    }
    
    @IBAction func addArray(_ sender: Any) {
        DispatchQueue.global().async {
            let kGirls = Girl.fetchRandomList()
            DispatchQueue.main.sync { [weak self] in
                guard let self = self else { return }
                var indexPaths: [IndexPath] = []
                for i in 0 ..< kGirls.count {
                    indexPaths.append(IndexPath(item: i + self.girls.count, section: 0))
                }
                self.girls += kGirls
                self.animateUpdate { collectionView in
                    collectionView.insertItems(at: indexPaths)
                }
            }
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
        girls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! GirlCell
        cell.girl = girls[indexPath.item]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch segmentedControl.selectedSegmentIndex {
        // 增
        case 0:
            girls.insert(Girl.fetchRandomOne(), at: indexPath.item)
            animateUpdate { $0.insertItems(at: [indexPath]) }
            
        // 删
        case 1:
            girls.remove(at: indexPath.item)
            animateUpdate { $0.deleteItems(at: [indexPath]) }
            
        // 改
        case 2:
            girls[indexPath.item] = Girl.fetchRandomOne()
            animateUpdate { $0.reloadItems(at: [indexPath]) }
            
        default:
            break
        }
    }
}

extension ViewController: WaterfallLayoutDelegate {
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        var girl = girls[index]
        if girl.cellSize.width != itemWidth {
            girl.cellSize = CGSize(width: itemWidth, height: itemWidth / girl.whRatio)
            girls[index] = girl
        }
        return girl.cellSize.height
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
        var safeAreaInsets: UIEdgeInsets = UIApplication.shared.keyWindow?.safeAreaInsets ?? .zero
        safeAreaInsets.top += 44 + 5
        safeAreaInsets.left += 5
        safeAreaInsets.bottom += 49 + 5
        safeAreaInsets.right += 5
        return safeAreaInsets
    }
}
