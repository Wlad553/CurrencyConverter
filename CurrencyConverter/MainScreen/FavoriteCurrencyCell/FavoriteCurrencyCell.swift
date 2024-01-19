//
//  FavoriteCurrencyCell.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import UIKit
import SnapKit
import RxSwift

final class FavoriteCurrencyCell: UITableViewCell {
    static let reuseIdentifier = "FavoriteCurrencyCell"
    
    let amountTextField = UITextField()
    
    let hStack = UIStackView()
    let currencyLabel = UILabel()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        
    private let disposeBag = DisposeBag()
    
    var viewModel: CurrencyCellViewModelType? {
        didSet {
            subscribeToCurrency()
        }
    }
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = false
        setUpHStackViews()
        setUpTextField()
        addConstraints()
        subscribeToTextFieldEvents()
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
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
        addSubview(amountTextField)

        amountTextField.accessibilityIdentifier = "cellTextField"
        amountTextField.textColor = .deepDarkGray
        amountTextField.backgroundColor = .gainsboro
        
        amountTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: amountTextField.frame.size.height))
        amountTextField.leftViewMode = .always
        amountTextField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 8, height: amountTextField.frame.size.height))
        amountTextField.rightViewMode = .always
        
        amountTextField.layer.borderColor = UIColor.dodgerBlue.cgColor
        amountTextField.layer.cornerRadius = 5
        
        amountTextField.borderStyle = .none
        amountTextField.keyboardType = .decimalPad
    }
    
    // MARK: - Constraints
    private func addConstraints() {
        hStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().offset(32)
            make.width.equalTo(60)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(hStack.snp.trailing).offset(60)
            make.trailing.equalToSuperview().inset(32)
            make.height.equalTo(40)
        }
    }
    
    // MARK: - Subscriptions
    private func subscribeToCurrency() {
        viewModel?.currency
            .subscribe(onNext: { [weak self] currency in
                self?.currencyLabel.text = currency.code
            })
            .disposed(by: disposeBag)
    }
    
    private func subscribeToTextFieldEvents() {
        amountTextField.rx
            .controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] event in
                guard let parentTableView = self?.superview as? UITableView, !parentTableView.isEditing
                else {
                    self?.amountTextField.resignFirstResponder()
                    return
                }
                
                self?.amountTextField.layer.borderWidth = 1
                self?.amountTextField.textColor = .darkBlue
            })
            .disposed(by: disposeBag)
        
        amountTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] event in
                self?.amountTextField.layer.borderWidth = 0
                self?.amountTextField.textColor = .deepDarkGray
            })
            .disposed(by: disposeBag)
        
        amountTextField.rx
            .controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] event in
                self?.amountTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        amountTextField.rx.text
            .orEmpty
            .scan(String(), accumulator: { previousText, newText in
                let formatter = ConverterNumberFormatter()
                return formatter.applyFormat(previousText: previousText, currentText: newText)
            })
            .bind(to: amountTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - Animations
extension FavoriteCurrencyCell {
    func isEditingToggle(animated: Bool, isTableViewEditing: Bool) {
        hStack.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(isTableViewEditing ? 56 : 32)
        }
        amountTextField.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(isTableViewEditing ? 56 : 32)
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
        }
    }
}
