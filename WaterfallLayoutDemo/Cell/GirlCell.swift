//
//  GirlCell.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit
import SnapKit

class GirlCell: UICollectionViewCell {
    let imgView = UIImageView()
    
    var girl: Girl? {
        didSet {
            guard let girl = self.girl else { return }
            imgView.image = UIImage(contentsOfFile: Bundle.main.path(forResource: girl.imgName, ofType: "jpg")!)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imgView.layer.cornerRadius = 5
        imgView.layer.masksToBounds = true
        imgView.backgroundColor = .lightGray
        contentView.addSubview(imgView)
        imgView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
