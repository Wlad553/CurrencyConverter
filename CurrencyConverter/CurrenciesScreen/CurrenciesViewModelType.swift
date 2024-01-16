//
//  CurrenciesViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Foundation
import RxRelay

protocol CurrenciesViewModelType: AnyObject {
    var availableCurrencies: [Currency] { get }
    var displayedCurrencies: BehaviorRelay<[SectionOfCurrencies]> { get }
    var searchControllerManager: SearchControllerManager { get }
    
    func triggerUnwind(selectedCurrency: Currency)
}
