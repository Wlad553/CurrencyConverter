//
//  MainView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 20/04/2023.
//

import UIKit

class MainWindowView: UIView {
    @IBOutlet weak var sellButton: UIButton!
    @IBOutlet weak var buyButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addCurrencyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func layoutSubviews() {
        layer.shadowPath = CGPath(rect: CGRect(x: 5, y: 20, width: bounds.width - 10, height: bounds.height - 15), transform: nil)
    }
    
    func setUpView() {
        setUpButtons()
        setUpMainWindowView()
        setUpTableView()
    }
    
    private func setUpTableView() {
        tableView.rowHeight = 70
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
    }
    
    private func setUpButtons() {
        buyButton.layer.backgroundColor = CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1)
        [sellButton, buyButton].forEach { button in
            button?.layer.cornerRadius = 10
        }
    }
    
    private func setUpMainWindowView() {
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.shadowPath = CGPath(rect: CGRect(x: 5, y: 20, width: bounds.width - 10, height: bounds.height - 15), transform: nil)
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
