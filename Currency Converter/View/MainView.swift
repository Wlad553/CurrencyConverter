//
//  MainView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 20/04/2023.
//

import UIKit

class MainView: UIView {
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    
    func setUpButtons() {
        buyButton.layer.backgroundColor = CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1)
        [sellButton, buyButton].forEach { button in
            button?.layer.cornerRadius = 10
        }
    }
    
    @IBAction func sellBuyButtonAction(sender: UIButton) {
            UIView.animate(withDuration: 0.2) {
                sender.layer.backgroundColor = CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1)
            }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                sender.isEnabled = false
            }
        for button in [sellButton, buyButton] {
            guard button != sender else { continue }
            UIView.animate(withDuration: 0.2) {
                button!.layer.backgroundColor = UIColor.white.cgColor
            }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
                button!.isEnabled = true
            }
        }
    }
}
