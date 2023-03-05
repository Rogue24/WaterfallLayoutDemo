# WaterfallLayout

> 自带过渡效果的UICollectionView瀑布流布局。

    Feature：
        ✅ 自带过渡效果；
        ✅ 可自定义列数、间距等属性；
        ✅ 适配横竖屏；
        ✅ 提供异步刷新；
        ✅ 兼容 OC & Swift；
        ✅ API简单易用。

## 效果

- 整体刷新效果

![WaterfallLayout_1.gif](https://github.com/Rogue24/JPCover/raw/master/WaterfallLayout/WaterfallLayout_1.gif)

- 列数变化效果

![WaterfallLayout_2.gif](https://github.com/Rogue24/JPCover/raw/master/WaterfallLayout/WaterfallLayout_2.gif)

- 增/删/改效果

![WaterfallLayout_3.gif](https://github.com/Rogue24/JPCover/raw/master/WaterfallLayout/WaterfallLayout_3.gif)

- 适配横竖屏

![WaterfallLayout_4.gif](https://github.com/Rogue24/JPCover/raw/master/WaterfallLayout/WaterfallLayout_4.gif)

## 使用

1. 只需将`WaterfallLayout.swift`文件拖进项目

2. 初始化`waterfallLayout`及`collectionView`并成为其代理
```swift
let waterfallLayout = WaterfallLayout()
waterfallLayout.delegate = self

let collectionView = UICollectionView(frame: UIScreen.main.bounds, collectionViewLayout: waterfallLayout)
collectionView.delegate = self
collectionView.dataSource = self
view.addSubview(collectionView)
```

3. 实现`waterfallLayout`的代理方法，搞定
```swift
extension ViewController: WaterfallLayoutDelegate {
    /// 提供item的下标和（根据列数和间距得出）的宽度，需代理返回对应item的高度
    func waterfallLayout(_ waterfallLayout: WaterfallLayout, heightForItemAtIndex index: Int, itemWidth: CGFloat) -> CGFloat {
        // 具体可参考Demo
        let girl = girls[index]
        return itemWidth / girl.whRatio
    }
    
    ///【可选】cell的总列数
    func colCountInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> Int {
        4
    }
    
    ///【可选】cell的列间距
    func colMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5
    }
    
    ///【可选】cell的行间距
    func rowMarginInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> CGFloat {
        5
    }
    
    ///【可选】collectionView的内容间距
    func edgeInsetsInWaterFlowLayout(_ waterfallLayout: WaterfallLayout) -> UIEdgeInsets {
        UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
    }
}
```

4. 刷新布局
```swift
// 带动画刷新：使用自定义动画包裹collectionView的刷新操作
UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
    self.collectionView.performBatchUpdates {
        self.collectionView.reloadSections(IndexSet(integer: 0))
    }
}

// 不带动画刷新
collectionView.reloadData()
```

## Tips

1. 目前仅支持`UICollectionViewCell`和`单Section`的布局，也就是说不支持Section头、Section尾和多个Section的情况；

2. 当数据量庞大时，可使用异步刷新：
```swift
waterfallLayout.asyncUpdateLayout(itemTotal: girls.count) { [weak self] index, itemWidth in
    // 提供item的下标和（根据列数和间距得出）的宽度，返回对应item的高度
    guard let self = self else { return 1 }
    let girl = self.girls[index]
    return itemWidth / girl.whRatio
} completion: { [weak self] in
    // 刷新布局
    guard let self = self else { return }
    UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.88, initialSpringVelocity: 1) {
        self.collectionView.performBatchUpdates {
            self.collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}
```

PS：目前已做了初步优化，即便不使用异步刷新，在展示和滑动大量数据的列表（如用户相册）时也能保持页面流畅：

![WaterfallLayout_5.gif](https://github.com/Rogue24/JPCover/raw/master/WaterfallLayout/WaterfallLayout_5.gif)

- 后续迭代将不断优化！
