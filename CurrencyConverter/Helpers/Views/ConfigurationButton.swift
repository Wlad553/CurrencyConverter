//
//  ConfigurationButton.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import UIKit

final class ConfigurationButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configuration = .plain()
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        super.init(coder: coder)
    }
    
    override func updateConfiguration() {
        super.updateConfiguration()
        if state == .highlighted {
            alpha = 0.5
        } else if state == .normal {
            UIView.transition(with: self,
                              duration: 0.25,
                              options: .transitionCrossDissolve) {
                self.alpha = 1
            }
        } else if state == .disabled {
            alpha = 1
        }
    }
}
