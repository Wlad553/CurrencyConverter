//
//  MainViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift
import RxRelay

final class MainViewModel: MainViewModelType {
    let favoriteCurrencies: BehaviorSubject<[Currency]>
    let selectedPrice: BehaviorRelay<Currency.Price>
    
    // MARK: - Init
    init() {
        favoriteCurrencies = BehaviorSubject(value: [.usd, .eur, .pln, .rub])
        selectedPrice = BehaviorRelay(value: .bid)
    }
}
