//
//  CurrencyCell.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import UIKit
import RxSwift

final class CurrencyCell: UITableViewCell {
    static let reuseIdentifier = "CurrencyCell"
    
    private let disposeBag = DisposeBag()
    
    var viewModel: CurrencyCellViewModelType? {
        didSet {
            subscribeToCurrency()
        }
    }
    
    // MARK: - Inits
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        assert(false, "init(coder:) must not be used")
        super.init(coder: coder)
    }
    
    // MARK: - Subscriptions
    private func subscribeToCurrency() {
        viewModel?.currency
            .subscribe(onNext: { [weak self] currency in
                guard let self = self else { return }
                var contentConfiguration = defaultContentConfiguration()
                contentConfiguration.text = "\(currency.code) - \(currency.localizedName)"
                self.contentConfiguration = contentConfiguration
            })
            .disposed(by: disposeBag)
    }
}
