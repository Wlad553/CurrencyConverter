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

    let favoriteCurrencies: BehaviorSubject<[SectionOfCurrencies]>
    let selectedPrice: BehaviorRelay<Currency.Price>
    
    // MARK: - Init
    init(router: WeakRouter<AppRoute>) {
        self.router = router
        favoriteCurrencies = BehaviorSubject(value: [SectionOfCurrencies(items: [.usd, .eur, .pln, .ron])])
        selectedPrice = BehaviorRelay(value: .bid)
    }
    
    // MARK: Data manipulation
    func appendCurrencyToFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value() else { return }
        newCurrencyList[0].items.append(currency)
        favoriteCurrencies.onNext(newCurrencyList)
    }
    
    func deleteCurrencyFromFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value() else { return }
        newCurrencyList[0].items.removeAll { checkedCurrency in
            checkedCurrency == currency
        }
        favoriteCurrencies.onNext(newCurrencyList)
    }
    
    func moveCurrency(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var newCurrencyList = try? favoriteCurrencies.value(),
              let sourceCurrency = newCurrencyList[0].items[safe: sourceIndexPath.row]
        else { return }
        newCurrencyList[0].items.remove(at: sourceIndexPath.row)
        newCurrencyList[0].items.insert(sourceCurrency, at: destinationIndexPath.row)
        favoriteCurrencies.onNext(newCurrencyList)
    }
    
    // MARK: Navigation
    func prepareForTransition() {
        guard let currencies = try? favoriteCurrencies.value()[safe: 0]?.items else { return }
        router.trigger(.currencies(currenciesToExclude: currencies))
    }
}
