//
//  FavoriteCurrencyCellViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift

protocol CurrencyCellViewModelType: AnyObject {
    var currency: Observable<Currency> { get }
}
