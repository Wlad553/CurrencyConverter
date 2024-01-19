//
//  CurrencyProtocol.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 17/01/2024.
//

import Foundation

public protocol CurrencyProtocol {
    var code: String { get }
    var localizedName: String { get }
}
