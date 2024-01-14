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
        favoriteCurrencies = BehaviorSubject(value: [.usd, .eur, .pln, .rub])
        selectedPrice = BehaviorRelay(value: .bid)
    }
    
    // MARK: Navigation
    func prepareForTransition() {
        router.trigger(.currencies)
    }
}
