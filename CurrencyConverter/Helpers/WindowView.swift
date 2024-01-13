//
//  MainWindowView.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit

final class WindowView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.cornerRadius = 15
        backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(frame: .zero)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.shadowPath = CGPath(rect:CGRect(x: 5,
                                              y: 10,
                                              width: bounds.width - 10,
                                              height: bounds.height - 5), transform: nil)
    }
}
