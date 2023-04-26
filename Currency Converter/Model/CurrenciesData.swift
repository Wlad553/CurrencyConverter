//
//  CurrencyData.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import Foundation

struct CurrenciesData: Decodable {
    let quotes: [Quotes]
}

struct Quotes: Decodable {
    let ask: Double
    let bid: Double
    let baseCurrency: String
    let quoteCurrency: String
    
    enum CodingKeys: String, CodingKey {
        case ask, bid
        case baseCurrency = "base_currency"
        case quoteCurrency = "quote_currency"
    }
}

struct CurrencyParsedData {
    let quoteCurrency: Currency
    let baseCurrency = Currency(currencyCode: "USD")
    let askPrice: Double
    let bidPrice: Double
    
    init?(currencyData: CurrenciesData, currencyNumber: Int) {
        guard let currency = Currency(currencyCode: currencyData.quotes[currencyNumber].quoteCurrency) else { return nil }
        self.quoteCurrency = currency
        self.askPrice = currencyData.quotes[currencyNumber].ask
        self.bidPrice = currencyData.quotes[currencyNumber].bid
    }
}
