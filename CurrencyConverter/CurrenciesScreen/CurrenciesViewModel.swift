//
//  CurrenciesViewModel.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Foundation
import XCoordinator
import RxRelay

final class CurrenciesViewModel: CurrenciesViewModelType {
    private let router: WeakRouter<AppRoute>
    let availableCurrencies: [Currency]
    let displayedCurrencies: BehaviorRelay<[SectionOfCurrencies]>
    let searchControllerManager = SearchControllerManager()
    
    // MARK: - Init
    init(excludedCurrencies: [Currency], router: WeakRouter<AppRoute>) {
        self.availableCurrencies = Currency.availableCurrencies().filter { currency in
            !excludedCurrencies.contains(currency)
        }
        
        self.router = router
        displayedCurrencies = BehaviorRelay(value: availableCurrencies.alphabeticallyGroupedSections())
    }
    
    // MARK: Navigation
    func triggerUnwind(selectedCurrency: Currency) {
        router.trigger(.unwindMain(selectedCurrency: selectedCurrency))
    }
}
