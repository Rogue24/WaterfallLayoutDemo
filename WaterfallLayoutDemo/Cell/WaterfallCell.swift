//
//  WaterfallCell.swift
//  WaterfallLayoutDemo
//
//  Created by 周健平 on 2023/6/4.
//

import UIKit

class WaterfallCell: UICollectionViewCell {
    let imgView = UIImageView()
    
    var model: WaterfallModel? {
        didSet {
            guard let model = self.model else { return }
            imgView.image = model.image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imgView.layer.cornerRadius = 4
        imgView.layer.masksToBounds = true
        imgView.backgroundColor = .lightGray
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        let longGR = UILongPressGestureRecognizer(target: self, action: #selector(browse(_:)))
        longGR.minimumPressDuration = 0.25
        addGestureRecognizer(longGR)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func browse(_ longGR: UILongPressGestureRecognizer) {
        guard case .began = longGR.state else { return }
        BrowseImageView.show(from: self)
    }
}
