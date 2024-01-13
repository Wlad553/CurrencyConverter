//
//  FavoriteCurrencyCell.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit

final class FavoriteCurrencyCell: UITableViewCell {
    static let reuseIdentifier = "FavoriteCurrencyCell"
    
    let textField = UITextField()
    
    private let hStack = UIStackView()
    let currencyLabel = UILabel()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpHStackViews()
        setUpTextField()
        addConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    //MARK: - Subviews' setup
    private func setUpHStackViews() {
        // hStack
        addSubview(hStack)
        hStack.spacing = 3
        hStack.distribution = .fill
        hStack.axis = .horizontal
        
        // currencyLabel
        hStack.addArrangedSubview(currencyLabel)
        currencyLabel.font = UIFont(name: Fonts.Lato.regular, size: 17)
        currencyLabel.textColor = .darkBlue
        currencyLabel.accessibilityIdentifier = "cellCurrencyLabel"
        
        // chevronImageView
        hStack.addArrangedSubview(chevronImageView)
        chevronImageView.tintColor = currencyLabel.textColor
        chevronImageView.accessibilityIdentifier = "cellChevronImageView"
    }
    
    private func setUpTextField() {
        addSubview(textField)

        textField.accessibilityIdentifier = "cellTextField"
        textField.textColor = .deepDarkGray
        textField.backgroundColor = .gainsboro
        
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: textField.frame.size.height))
        textField.rightViewMode = .always
        
        textField.layer.borderColor = UIColor.dodgerBlue.cgColor
        textField.layer.cornerRadius = 5
        
        textField.borderStyle = .none
        textField.keyboardType = .decimalPad
    }
    
    // MARK: - Constraints
    private func addConstraints() {
        hStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.width.equalTo(40)
        }
        
        textField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(hStack.snp.trailing).offset(60)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(40)
        }
    }
}
