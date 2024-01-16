//
//  MainViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import XCoordinator
import RxSwift
import RxRelay

final class MainViewModel: MainViewModelType {
    private let router: WeakRouter<AppRoute>

    let favoriteCurrencies: BehaviorSubject<[Currency]>
    let selectedPrice: BehaviorRelay<Currency.Price>
    
    // MARK: - Init
    init(router: WeakRouter<AppRoute>) {
        self.router = router
        favoriteCurrencies = BehaviorSubject(value: [.usd, .eur, .pln])
        selectedPrice = BehaviorRelay(value: .bid)
    }
    
    // MARK: Data manipulation
    func appendCurrencyToFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value() else { return }
        newCurrencyList.append(currency)
        favoriteCurrencies.onNext(newCurrencyList)
    }
    
    // MARK: Navigation
    func prepareForTransition() {
        guard let currencies = try? favoriteCurrencies.value() else { return }
        router.trigger(.currencies(currenciesToExclude: currencies))
    }
}
