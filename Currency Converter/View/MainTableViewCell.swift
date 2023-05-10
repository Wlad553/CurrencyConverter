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
    var textFieldTrailingConstraint: NSLayoutConstraint!
    var stackViewLeadingConstraint: NSLayoutConstraint!
    
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
        currencyLabel.textColor = UIColor.currencyLabel
        chevronImageView.tintColor = currencyLabel.textColor
        
        stackView.addArrangedSubview(currencyLabel)
        stackView.addArrangedSubview(chevronImageView)
        
        stackView.spacing = 3
        stackView.distribution = .fill
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        stackViewLeadingConstraint = stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 60),
            stackViewLeadingConstraint,
        ])
    }
    
    private func setUpTextField() {
        textField.textColor = UIColor.inactiveText
        textField.backgroundColor = UIColor.textFieldBackground
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.rightViewMode = .always
        
        textField.layer.borderColor = UIColor.activeTextFieldBorder.cgColor
        textField.layer.cornerRadius = 5
        
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        addSubview(textField)
        
        textFieldTrailingConstraint = textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textFieldTrailingConstraint,
            textField.leadingAnchor.constraint(equalTo: currencyLabel.trailingAnchor, constant: 60),
            textField.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
}
