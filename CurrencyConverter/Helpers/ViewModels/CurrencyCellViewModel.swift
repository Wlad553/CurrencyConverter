//
//  FavoriteCurrencyCellViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxRelay

final class CurrencyCellViewModel: CurrencyCellViewModelType {
    let currency: BehaviorRelay<Currency>
    
    // MARK: - Init
    init(currency: Currency) {
        self.currency = BehaviorRelay(value: currency)
    }
}
