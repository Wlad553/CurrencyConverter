//
//  FavoriteCurrencyCellViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxRelay

protocol CurrencyCellViewModelType: AnyObject {
    var currency: BehaviorRelay<Currency> { get }
}
