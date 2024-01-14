//
//  CurrenciesViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Foundation
import RxRelay

protocol CurrenciesViewModelType: AnyObject {
    var currencies: BehaviorRelay<[SectionOfCurrencies]> { get }
}
