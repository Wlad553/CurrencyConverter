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
    
    let cellContentView = UIView()
    let hStack = UIStackView()
    let currencyLabel = UILabel()
    let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        
    private let disposeBag = DisposeBag()
    private var allowsTextFieldRxTextScan = true
    
    var viewModel: CurrencyCellViewModelType? {
        didSet {
            subscribeToCurrency()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        amountTextField.text = String()
    }
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.isUserInteractionEnabled = false
        setUpCellContentView()
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
    private func setUpCellContentView() {
        addSubview(cellContentView)
    }
    
    private func setUpHStackViews() {
        // hStack
        cellContentView.addSubview(hStack)
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
        cellContentView.addSubview(amountTextField)

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
        cellContentView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(361)
            make.trailing.leading.equalToSuperview().priority(999)
            make.height.equalTo(40)
        }
        
        hStack.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalToSuperview().inset(32)
            make.width.equalTo(60)
        }
        
        amountTextField.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.leading.equalTo(hStack.snp.trailing).offset(40)
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
                
                if let textFieldText = self?.amountTextField.text {
                    self?.allowsTextFieldRxTextScan = false
                    let formatter = ConverterNumberFormatter()
                    self?.amountTextField.text = formatter.applyConvertingFormat(previousText: textFieldText, currentText: textFieldText)
                }
            })
            .disposed(by: disposeBag)
        
        amountTextField.rx
            .controlEvent(.editingDidEnd)
            .subscribe(onNext: { [weak self] event in
                self?.allowsTextFieldRxTextScan = false

                self?.amountTextField.layer.borderWidth = 0
                self?.amountTextField.textColor = .deepDarkGray
                
                if let textFieldText = self?.amountTextField.text {
                    let formatter = ConverterNumberFormatter()
                    guard let textFieldTextNumber = formatter.number(from: textFieldText) else { return }
                    self?.amountTextField.text = formatter.convertToString(double: textFieldTextNumber.doubleValue)
                }
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
            .scan(String(), accumulator: { [self] previousText, newText in
                guard allowsTextFieldRxTextScan else {
                    allowsTextFieldRxTextScan.toggle()
                    return newText
                }
                
                let formatter = ConverterNumberFormatter()
                return formatter.applyConvertingFormat(previousText: previousText, currentText: newText)
            })
            .bind(to: amountTextField.rx.text)
            .disposed(by: disposeBag)
    }
}

// MARK: - Animations
extension FavoriteCurrencyCell {
    func isEditingToggle(animated: Bool, isTableViewEditing: Bool) {
        let cellFrameWidth = frame.width
        let cellContentViewWidth = cellContentView.frame.width
        var newInset: CGFloat = (48 - (cellFrameWidth - cellContentViewWidth)) / 2 + 32
        if newInset <= 32 {
            newInset = 32
        }
        
        hStack.snp.updateConstraints { make in
            make.leading.equalToSuperview().offset(isTableViewEditing ? newInset : 32)
        }
        amountTextField.snp.updateConstraints { make in
            make.trailing.equalToSuperview().inset(isTableViewEditing ? newInset : 32)
        }
        
        UIView.animate(withDuration: animated ? 0.3 : 0.0) {
            self.layoutIfNeeded()
        }
    }
}
