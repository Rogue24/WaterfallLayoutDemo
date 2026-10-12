//
//  NavActionSegments.swift
//  WaterfallLayoutDemo
//
//  Created by aa on 2026/10/12.
//

import UIKit

final class NavActionSegments: UIView {
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
