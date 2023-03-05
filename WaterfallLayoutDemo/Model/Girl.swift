//
//  Girl.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2023/3/5.
//

import UIKit

struct Girl: Identifiable {
    let id = UUID()
    let imgName: String
    let whRatio: CGFloat
    var cellSize: CGSize = .zero
    
    init(imgName: String) {
        self.imgName = imgName
        let image = UIImage(contentsOfFile: Bundle.main.path(forResource: imgName, ofType: "jpg")!)!
        self.whRatio = image.size.width / image.size.height
    }
    
    static func fetchRandomOne() -> Girl {
        Girl(imgName: "girl_\(Int.random(in: 1...16))")
    }
    
    static func fetchRandomList() -> [Girl] {
        let girlList = Array(1...16).map { Girl(imgName: "girl_\($0)") }
        return girlList.shuffled()
    }
}
