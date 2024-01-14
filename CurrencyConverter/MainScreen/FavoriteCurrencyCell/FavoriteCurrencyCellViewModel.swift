//
//  FavoriteCurrencyCellViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift

final class FavoriteCurrencyCellViewModel: FavoriteCurrencyCellViewModelType {
    let currency: Observable<Currency>
    
    // MARK: - Init
    init(currency: Currency) {
        self.currency = .just(currency)
    }
}
