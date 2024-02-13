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

    let favoriteCurrencies = BehaviorSubject<[SectionOfCurrencies]>(value: [])
    let ratesData = BehaviorSubject<[CurrencyRateData]>(value: [])
    let convertedAmounts = BehaviorRelay<[Currency: Double]>(value: [:])
    
    var selectedPrice: Currency.Price = .bid
    private var convertedCurrency: Currency?
    
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
    
    // MARK: - Network
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
    
    // MARK: Currency Converting
    func convert(amount: Double, convertedCurrency: Currency) {
        guard let ratesData = try? self.ratesData.value(),
              let favoriteCurrencies = try? self.favoriteCurrencies.value() else { return }
        var convertedAmounts: [Currency: Double] = [:]
        
        let baseCurrencySumToConvert: Double
        if convertedCurrency == .usd {
            baseCurrencySumToConvert = amount
        } else {
            guard let baseCurrencyCurrencyDataObject = ratesData.first(where: { dataObject in
                dataObject.quoteCurrency == convertedCurrency
            }) else { return }
            let convertedCurrencyPriceCoefficient = selectedPrice == .bid ? baseCurrencyCurrencyDataObject.bidPrice : baseCurrencyCurrencyDataObject.askPrice
            baseCurrencySumToConvert = amount / convertedCurrencyPriceCoefficient
        }
        
        if let usdCurrency = favoriteCurrencies.first?.items.first(where: { $0 == .usd }) {
            convertedAmounts[usdCurrency] = baseCurrencySumToConvert
        }
        
        ratesData.forEach { rateDataObject in
            guard favoriteCurrencies[0].items.contains(rateDataObject.quoteCurrency) else { return }
            let convertedCurrencyPriceCoefficient = selectedPrice == .bid ? rateDataObject.bidPrice : rateDataObject.askPrice
            convertedAmounts[rateDataObject.quoteCurrency] = baseCurrencySumToConvert * convertedCurrencyPriceCoefficient
        }
        
        self.convertedAmounts.accept(convertedAmounts)
        self.convertedCurrency = convertedCurrency
    }
    
    func updateConvertedAmountsIfNeeded() {
        guard let convertedCurrency = convertedCurrency,
              let convertedCurrencyAmount = convertedAmounts.value[convertedCurrency] else { return }
        
        convert(amount: convertedCurrencyAmount, convertedCurrency: convertedCurrency)
        
        if !convertedAmounts.value.keys.contains(convertedCurrency) {
            self.convertedCurrency = nil
            self.convertedAmounts.accept([:])
        }
    }
    
    // MARK: Manipulation with Favorite Currencies
    func appendCurrencyToFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value()[safe: 0] else { return }
        newCurrencyList.items.append(currency)
        favoriteCurrencies.onNext([newCurrencyList])
        
        coreDataManager.saveFavoriteCurrency(currency: currency)
        updateConvertedAmountsIfNeeded()
    }
    
    func deleteCurrencyFromFavorites(_ currency: Currency) {
        guard var newCurrencyList = try? favoriteCurrencies.value()[safe: 0] else { return }
        newCurrencyList.items.removeAll { checkedCurrency in
            checkedCurrency == currency
        }
        favoriteCurrencies.onNext([newCurrencyList])
        
        coreDataManager.deleteFavoriteCurrency(currency: currency)
        updateConvertedAmountsIfNeeded()
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
    
    // MARK: Utility Methods
    func stringToShare() -> String? {
        guard let currencies = try? favoriteCurrencies.value()[safe: 0]?.items else { return nil }
        var stringToShare = ""
        let formatter = ConverterNumberFormatter()
        
        currencies.forEach { currency in
            guard let convertedCurrencyAmount = convertedAmounts.value[currency] else { return }
            let formattedAmount = formatter.convertToString(double:  convertedCurrencyAmount)
            stringToShare.append(("\(currency.code) \(formattedAmount)\n"))
        }
        
        return stringToShare
    }
    
    func dateFormattedRequestTime(requestTimestamp: Double) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: Date(timeIntervalSince1970: requestTimestamp))
    }
    
    // MARK: Navigation
    func prepareForTransition() {
        guard let currencies = try? favoriteCurrencies.value()[safe: 0]?.items else { return }
        router.trigger(.currencies(currenciesToExclude: currencies))
    }
}
