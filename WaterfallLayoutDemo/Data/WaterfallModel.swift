//
//  WaterfallModel.swift
//  WaterfallLayoutDemo
//
//  Created by 周健平 on 2023/6/4.
//

import UIKit

class WaterfallModel {
    let image: UIImage
    let imageIndex: Int
    
    init(image: UIImage, imageIndex: Int) {
        self.image = image
        self.imageIndex = imageIndex
    }
    
    private(set) var cellSize: CGSize = .zero
    func resetCellSize(for cellWidth: CGFloat) {
        guard cellWidth != cellSize.width else { return }
        cellSize = CGSize(width: cellWidth, height: cellWidth * (image.size.height / image.size.width))
    }
}
