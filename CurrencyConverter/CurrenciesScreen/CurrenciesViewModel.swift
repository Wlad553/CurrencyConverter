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
    let currencies: BehaviorRelay<[SectionOfCurrencies]>
    
    init(router: WeakRouter<AppRoute>) {
        self.router = router
        currencies = BehaviorRelay(value: SectionOfCurrencies.sectionsOfCurrenciesSorted())
    }
}
