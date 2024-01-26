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
import OSLog

final class MainViewModel: MainViewModelType {
    private let router: WeakRouter<AppRoute>

    let favoriteCurrencies = BehaviorSubject<[SectionOfCurrencies]>(value: [])
    let selectedPrice = BehaviorRelay<Currency.Price>(value: .bid)
    
    let coreDataManager: CoreDataManager
    
    // MARK: - Init
    init(router: WeakRouter<AppRoute>, coreDataManager: CoreDataManager) {
        self.router = router
        self.coreDataManager = coreDataManager
        
        favoriteCurrencies.onNext([SectionOfCurrencies(items: coreDataManager.getFavouriteCurrencies())])
    }
    
    // MARK: - Utility Methods
    
    // MARK: Manipulation with Favorite Currencies
    func appendCurrencyToFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value()[safe: 0] else { return }
        newCurrencyList.items.append(currency)
        favoriteCurrencies.onNext([newCurrencyList])
        
        coreDataManager.saveFavoriteCurrency(currency: currency)
    }
    
    func deleteCurrencyFromFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value()[safe: 0] else { return }
        newCurrencyList.items.removeAll { checkedCurrency in
            checkedCurrency == currency
        }
        favoriteCurrencies.onNext([newCurrencyList])
        
        coreDataManager.deleteFavoriteCurrency(currency: currency)
    }
    
    func moveCurrency(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard var newCurrencyList = try? favoriteCurrencies.value()[safe: 0],
              let sourceCurrency = newCurrencyList.items[safe: sourceIndexPath.row]
        else { return }
        newCurrencyList.items.remove(at: sourceIndexPath.row)
        newCurrencyList.items.insert(sourceCurrency, at: destinationIndexPath.row)
        favoriteCurrencies.onNext([newCurrencyList])
        
        coreDataManager.moveFavoriteCurrency(newCurrenciesList: newCurrencyList.items)
    }
    
    // MARK: Navigation
    func prepareForTransition() {
        guard let currencies = try? favoriteCurrencies.value()[safe: 0]?.items else { return }
        router.trigger(.currencies(currenciesToExclude: currencies))
    }
}
