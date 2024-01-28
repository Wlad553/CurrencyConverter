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
    var selectedPrice: BehaviorRelay<Currency.Price> { get }
    var ratesData: BehaviorSubject<[CurrencyRateData]> { get }
    
    var coreDataManager: CoreDataManager { get }
    var networkCurrenciesDataManager: NetworkRatesDataManagerProtocol { get }
        
    func fetchRatesDataIfNeeded()
    
    func appendCurrencyToFavorites(_ currency: Currency)
    func deleteCurrencyFromFavorites(_ currency: Currency)
    func moveCurrency(from sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    
    func prepareForTransition()
}
