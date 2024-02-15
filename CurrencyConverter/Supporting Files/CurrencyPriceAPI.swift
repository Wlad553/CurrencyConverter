//
//  CurrencyPriceAPI.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 22/01/2024.
//

import Foundation
struct CurrencyPriceAPI {
    static let key = ProcessInfo.processInfo.environment["API_KEY"]
    static let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=\(Currency.availableCurrencyPairs())&api_key=\(Self.key ?? String())"
    
    private init() {}
}
