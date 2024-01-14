//
//  MainViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift

final class MainViewModel: MainViewModelType {
    var favoriteCurrencies: BehaviorSubject<[Currency]>
    
    // MARK: - Init
    init() {
        favoriteCurrencies = BehaviorSubject(value: [.usd, .eur, .pln, .rub])
    }
}
