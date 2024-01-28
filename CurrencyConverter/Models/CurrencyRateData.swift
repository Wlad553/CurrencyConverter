//
//  CurrencyRateData.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import Foundation
import OSLog

public struct CurrencyRateData {
    let baseCurrency: CurrencyProtocol = Currency.usd
    let quoteCurrency: CurrencyProtocol
    let askPrice: Double
    let bidPrice: Double
    let requestTimestamp: Double
    
    init(currencyRatesRawData: CurrencyRatesRawData, index: Int) throws {
        guard let quoteCurrency = Currency(rawValue: currencyRatesRawData.quotes[index].quoteCurrency.lowercased()) else {
            throw CurrencyError.nonExistingCurrency
        }
        self.quoteCurrency = quoteCurrency
        self.askPrice = currencyRatesRawData.quotes[index].ask
        self.bidPrice = currencyRatesRawData.quotes[index].bid
        self.requestTimestamp = Double(currencyRatesRawData.timestamp)
    }
    
    init(currencyRateSavedData: CurrencyRateSavedData) throws {
        guard let quoteCurrency = Currency(rawValue: currencyRateSavedData.quoteCurrency?.lowercased() ?? String()) else {
            throw CurrencyError.nonExistingCurrency
        }
        self.quoteCurrency = quoteCurrency
        self.askPrice = currencyRateSavedData.askPrice
        self.bidPrice = currencyRateSavedData.bidPrice
        self.requestTimestamp = currencyRateSavedData.requestTimestamp
    }
}

struct CurrencyRatesRawData: Decodable {
    let quotes: [Quotes]
    let timestamp: Int
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
