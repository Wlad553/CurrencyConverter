//
//  MainViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift
import RxRelay

protocol MainViewModelType: AnyObject {
    var favoriteCurrencies: BehaviorSubject<[SectionOfCurrencies]> { get }
    var ratesData: BehaviorSubject<[CurrencyRateData]> { get }
    var convertedAmounts: BehaviorRelay<[Currency: Double]> { get }

    var selectedPrice: Currency.Price { get set }
    
    var coreDataManager: CoreDataManager { get }
    var networkCurrenciesDataManager: NetworkRatesDataManagerProtocol { get }
        
    func fetchRatesDataIfNeeded()
    
    func convert(amount: Double, convertedCurrency: Currency)
    func updateConvertedAmountsIfNeeded()
    
    func appendCurrencyToFavorites(_ currency: Currency)
    func deleteCurrencyFromFavorites(_ currency: Currency)
    func moveCurrency(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    func stringToShare() -> String?
    func dateFormattedRequestTime(requestTimestamp: Double) -> String
    
    func prepareForTransition()
}
