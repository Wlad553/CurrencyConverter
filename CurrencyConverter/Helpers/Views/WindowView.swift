//
//  MainWindowView.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit
import QuartzCore

final class WindowView: UIView {
    private let animation = CABasicAnimation(keyPath: "shadowPath")
    
    var isShadowPathAnimationEnabled = false
    
    override var bounds: CGRect {
        willSet {
            animation.fromValue = CGPath(rect:CGRect(x: 5,
                                                     y: 10,
                                                     width: bounds.width - 10,
                                                     height: bounds.height - 5),
                                         transform: nil)
        }
    }
    
    // MARK: - Inits
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.cornerRadius = 15
        backgroundColor = .systemBackground
        setUpAnimationForShadowPathChange()
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        super.init(coder: coder)
    }
    
    // MARK: - Overridden methods
    override func layoutSubviews() {
        super.layoutSubviews()
        if isShadowPathAnimationEnabled {
            layer.add(animation, forKey: "shadowPathAnimation")
        }
        layer.shadowPath = CGPath(rect:CGRect(x: 5,
                                              y: 10,
                                              width: bounds.width - 10,
                                              height: bounds.height - 5),
                                  transform: nil)
    }
    
    //MARK: Animation
    private func setUpAnimationForShadowPathChange() {
        animation.isRemovedOnCompletion = true
        animation.duration = 0.3
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
    }
}
