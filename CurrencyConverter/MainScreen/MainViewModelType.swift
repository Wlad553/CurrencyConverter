//
//  MainViewModelType.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation
import RxSwift

protocol MainViewModelType: AnyObject {
    var favoriteCurrencies: BehaviorSubject<[Currency]> { get }
}
