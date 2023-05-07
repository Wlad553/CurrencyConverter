//
//  MainView.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 20/04/2023.
//

import UIKit

final class MainWindowView: UIView {
    @IBOutlet weak var askButton: UIButton!
    @IBOutlet weak var bidButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var addCurrencyButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    var selectedButton: UIButton!
    
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
        bidButton.isEnabled = false
        selectedButton = bidButton
        
        bidButton.layer.backgroundColor = CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1)
        askButton.layer.backgroundColor = UIColor.white.cgColor
        [askButton, bidButton].forEach { button in
            guard let button = button else { return }
            button.layer.cornerRadius = 10
        }

        if #available(iOS 15.0, *) {
            var configuration = UIButton.Configuration.plain()
            configuration.imagePadding = 5
            addCurrencyButton.configuration = configuration
        } else {
            addCurrencyButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 0)
        }
        
    }
    
    private func setUpMainWindowView() {
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        layer.shadowPath = CGPath(rect: CGRect(x: 5, y: 20, width: bounds.width - 10, height: bounds.height - 15), transform: nil)
    }
    
    @IBAction func bidAskButtonUIUpdateAction(sender: UIButton) {
        selectedButton = sender
        UIView.animate(withDuration: 0.2) {
            sender.layer.backgroundColor = CGColor(red: 10/255, green: 95/255, blue: 255/255, alpha: 1)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // disable a button in the middle of animation duration so that the color smoothly changed from black to white
            sender.isEnabled = false
        }
        for button in [bidButton, askButton] {
            guard button != sender, let button = button else { continue }
            UIView.animate(withDuration: 0.2) {
                button.layer.backgroundColor = UIColor.white.cgColor
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                button.isEnabled = true
            }
        }
    }
}
