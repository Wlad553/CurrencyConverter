//
//  MainTableViewCell.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 21/04/2023.
//

import UIKit

class MainTableViewCell: UITableViewCell {
    
    let textField = UITextField()
    let currencyLabel = UILabel()
    let arrowImageView = UIImageView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpCurrencyLabel()
        setUpCommonTextField()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    private func setUpCurrencyLabel() {
        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currencyLabel)
        
        NSLayoutConstraint.activate([
            currencyLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            currencyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
        ])
    }
    
    private func setUpCommonTextField() {
        textField.borderStyle = .none
        textField.backgroundColor = UIColor(red: 240/255, green: 241/255, blue: 245/255, alpha: 1)
//        textField.backgroundColor = UIColor(red: 245/255, green: 246/255, blue: 250/255, alpha: 1)
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 60),
            textField.heightAnchor.constraint(equalToConstant: 40),
        ])
        
        textField.layer.cornerRadius = 5
        // text padding by 8 points
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.rightViewMode = .always
        
        textField.layer.borderColor = CGColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        
        textField.keyboardType = .decimalPad
    }
}
