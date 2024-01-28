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
    let ratesData = BehaviorSubject<[CurrencyRateData]>(value: [])
    
    let coreDataManager: CoreDataManager
    let networkCurrenciesDataManager: NetworkRatesDataManagerProtocol
    
    // MARK: - Init
    init(router: WeakRouter<AppRoute>,
         coreDataManager: CoreDataManager,
         networkCurrenciesDataManager: NetworkRatesDataManagerProtocol) {
        self.router = router
        self.coreDataManager = coreDataManager
        self.networkCurrenciesDataManager = networkCurrenciesDataManager
        
        favoriteCurrencies.onNext([SectionOfCurrencies(items: coreDataManager.getFavoriteCurrencies())])
        ratesData.onNext(coreDataManager.getCurrencyRatesData())
    }
    
    // MARK: - Utility Methods
    func fetchRatesDataIfNeeded() {
        Task {
            do {
                let ratesData = try await networkCurrenciesDataManager.fetchDataIfNeeded(savedRatesData: coreDataManager.getCurrencyRatesData())
                self.ratesData.onNext(ratesData)
                coreDataManager.updateCurrencyRatesSavedDataObjects(with: ratesData)
            } catch {
                Task.detached {
                    await MainActor.run {
                        self.ratesData.onError(error)
                    }
                }
            }
        }
    }
    
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
