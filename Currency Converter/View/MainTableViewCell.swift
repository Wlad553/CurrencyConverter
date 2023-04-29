//
//  MainTableViewCell.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 21/04/2023.
//

import UIKit

final class MainTableViewCell: UITableViewCell {
    let textField = UITextField()
    let currencyLabel = UILabel()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    let stackView = UIStackView()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUpLeftSideOfView()
        setUpTextField()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    private func setUpLeftSideOfView() {
        currencyLabel.font = UIFont(name: "Lato-Regular", size: 17)
        currencyLabel.textColor = UIColor(red: 1/255, green: 35/255, blue: 83/255, alpha: 1)
        chevronImageView.tintColor = currencyLabel.textColor
        
        stackView.addArrangedSubview(currencyLabel)
        stackView.addArrangedSubview(chevronImageView)
        
        stackView.spacing = 8
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
        ])
    }
    
    private func setUpTextField() {
        textField.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
        textField.backgroundColor = UIColor(red: 240/255, green: 241/255, blue: 245/255, alpha: 1)
        
        // text padding by 8 points
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.rightViewMode = .always
        
        textField.layer.borderColor = CGColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        textField.layer.cornerRadius = 5
        
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            textField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 60),
            textField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
