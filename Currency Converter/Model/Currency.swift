//
//  File.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 24/04/2023.
//

import Foundation

struct Currency: Hashable {
    let currencyCode: String
    var fullCurrencyName: String {
        Currency.availableCurrenciesDict[currencyCode]!
    }
    
    init?(currencyCode: String) {
        guard Currency.availableCurrenciesDict[currencyCode] != nil else {
            return nil
        }
        self.currencyCode = currencyCode
    }
    
    static let availableCurrenciesDict = [
        "AED": "UAE Dirham",
        "AOA": "Angolan Kwanza",
        "ARS": "Argentine Peso",
        "AUD": "Australian Dollar",
        "BGN": "Bulgaria Lev",
        "BHD": "Bahraini Dinar",
        "BRL": "Brazilian Real",
        "CAD": "Canadian Dollar",
        "CHF": "Swiss Franc",
        "CLP": "Chilean Peso",
        "CNY": "Chinese Yuan onshore",
        "CNH": "Chinese Yuan offshore",
        "COP": "Colombian Peso",
        "CZK": "Czech Koruna",
        "DKK": "Danish Krone",
        "EUR": "Euro",
        "GBP": "British Pound Sterling",
        "HKD": "Hong Kong Dollar",
        "HRK": "Croatian Kuna",
        "HUF": "Hungarian Forint",
        "IDR": "Indonesian Rupiah",
        "ILS": "Israeli New Sheqel",
        "INR": "Indian Rupee",
        "ISK": "Icelandic Krona",
        "JPY": "Japanese Yen",
        "KRW": "South Korean Won",
        "KWD": "Kuwaiti Dinar",
        "MAD": "Moroccan Dirham",
        "MXN": "Mexican Peso",
        "MYR": "Malaysian Ringgit",
        "NGN": "Nigerean Naira",
        "NOK": "Norwegian Krone",
        "NZD": "New Zealand Dollar",
        "OMR": "Omani Rial",
        "PEN": "Peruvian Nuevo Sol",
        "PHP": "Philippine Peso",
        "PLN": "Polish Zloty",
        "RON": "Romanian Leu",
        "RUB": "Russian Ruble",
        "SAR": "Saudi Arabian Riyal",
        "SEK": "Swedish Krona",
        "SGD": "Singapore Dollar",
        "THB": "Thai Baht",
        "TRY": "Turkish Lira",
        "TWD": "Taiwanese Dollar",
        "USD": "US Dollar",
        "VND": "Vietnamese Dong",
        "XAG": "Silver (troy ounce)",
        "XAU": "Gold (troy ounce)",
        "XPD": "Palladium",
        "XPT": "Platinum",
        "ZAR": "South African Rand"
    ]
    
    static var availableCurrenciesSet: Set<Currency> {
        var set: Set<Currency> = []
        for i in availableCurrenciesDict {
            guard let currency = Currency(currencyCode: i.key) else { continue }
            set.insert(currency)
        }
        return set
    }
}
