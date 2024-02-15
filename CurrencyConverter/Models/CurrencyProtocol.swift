//
//  CurrencyProtocol.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 17/01/2024.
//

import Foundation
import Differentiator

public protocol CurrencyProtocol {
    var code: String { get }
    var localizedName: String { get }
}
