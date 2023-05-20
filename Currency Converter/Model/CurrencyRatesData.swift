//
//  CurrencyData.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import Foundation

struct CurrencyRatesData: Decodable {
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

public struct CurrencyRatesParsedData {
    let baseCurrency = Currency(currencyCode: "USD")!
    let quoteCurrency: Currency
    let askPrice: Double
    let bidPrice: Double
    
    init?(currencyRatesData: CurrencyRatesData, currencyNumber: Int) {
        guard let currency = Currency(currencyCode: currencyRatesData.quotes[currencyNumber].quoteCurrency) else { return nil }
        self.quoteCurrency = currency
        self.askPrice = currencyRatesData.quotes[currencyNumber].ask
        self.bidPrice = currencyRatesData.quotes[currencyNumber].bid
    }
}
