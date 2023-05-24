//
//  MockCurrenciesSet.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 23/05/2023.
//

import Foundation
import Currency_Converter

struct MockCurrency: CurrencyProtocol {
    var currencyCode: String
    var fullCurrencyName: String {
        let fullCurrencyName: String
        switch currencyCode {
        case "AED": fullCurrencyName = "UAE Dirham"
        case "AOA": fullCurrencyName = "Angolan Kwanza"
        case "ARS": fullCurrencyName = "Argentine Peso"
        case "AUD": fullCurrencyName = "Australian Dollar"
        case "BGN": fullCurrencyName = "Bulgaria Lev"
        case "BHD": fullCurrencyName = "Bahraini Dinar"
        case "BRL": fullCurrencyName = "Brazilian Real"
        case "CAD": fullCurrencyName = "Canadian Dollar"
        case "CHF": fullCurrencyName = "Swiss Franc"
        case "CLP": fullCurrencyName = "Chilean Peso"
        case "CNY": fullCurrencyName = "Chinese Yuan onshore"
        case "CNH": fullCurrencyName = "Chinese Yuan offshore"
        case "COP": fullCurrencyName = "Colombian Peso"
        case "CZK": fullCurrencyName = "Czech Koruna"
        case "DKK": fullCurrencyName = "Danish Krone"
        case "EUR": fullCurrencyName = "Euro"
        case "GBP": fullCurrencyName = "British Pound Sterling"
        case "HKD": fullCurrencyName = "Hong Kong Dollar"
        case "HRK": fullCurrencyName = "Croatian Kuna"
        case "HUF": fullCurrencyName = "Hungarian Forint"
        case "IDR": fullCurrencyName = "Indonesian Rupiah"
        case "ILS": fullCurrencyName = "Israeli New Sheqel"
        case "INR": fullCurrencyName = "Indian Rupee"
        case "ISK": fullCurrencyName = "Icelandic Krona"
        case "JPY": fullCurrencyName = "Japanese Yen"
        case "KRW": fullCurrencyName = "South Korean Won"
        case "KWD": fullCurrencyName = "Kuwaiti Dinar"
        case "MAD": fullCurrencyName = "Moroccan Dirham"
        case "MXN": fullCurrencyName = "Mexican Peso"
        case "MYR": fullCurrencyName = "Malaysian Ringgit"
        case "NGN": fullCurrencyName = "Nigerean Naira"
        case "NOK": fullCurrencyName = "Norwegian Krone"
        case "NZD": fullCurrencyName = "New Zealand Dollar"
        case "OMR": fullCurrencyName = "Omani Rial"
        case "PEN": fullCurrencyName = "Peruvian Nuevo Sol"
        case "PHP": fullCurrencyName = "Philippine Peso"
        case "PLN": fullCurrencyName = "Polish Zloty"
        case "RON": fullCurrencyName = "Romanian Leu"
        case "RUB": fullCurrencyName = "Russian Ruble"
        case "SAR": fullCurrencyName = "Saudi Arabian Riyal"
        case "SEK": fullCurrencyName = "Swedish Krona"
        case "SGD": fullCurrencyName = "Singapore Dollar"
        case "THB": fullCurrencyName = "Thai Baht"
        case "TRY": fullCurrencyName = "Turkish Lira"
        case "TWD": fullCurrencyName = "Taiwanese Dollar"
        case "USD": fullCurrencyName = "US Dollar"
        case "VND": fullCurrencyName = "Vietnamese Dong"
        case "XAG": fullCurrencyName = "Silver (troy ounce)"
        case "XAU": fullCurrencyName = "Gold (troy ounce)"
        case "XPD": fullCurrencyName = "Palladium"
        case "XPT": fullCurrencyName = "Platinum"
        case "ZAR": fullCurrencyName = "South African Rand"
        default: fullCurrencyName = "unknown"
        }
        return fullCurrencyName
    }
    
    static let currenciesSet: Set<MockCurrency> = [
        MockCurrency(currencyCode: "AED"),
        MockCurrency(currencyCode: "AOA"),
        MockCurrency(currencyCode: "ARS"),
        MockCurrency(currencyCode: "AUD"),
        MockCurrency(currencyCode: "BGN"),
        MockCurrency(currencyCode: "BHD"),
        MockCurrency(currencyCode: "BRL"),
        MockCurrency(currencyCode: "CAD"),
        MockCurrency(currencyCode: "CHF"),
        MockCurrency(currencyCode: "CLP"),
        MockCurrency(currencyCode: "CNY"),
        MockCurrency(currencyCode: "CNH"),
        MockCurrency(currencyCode: "COP"),
        MockCurrency(currencyCode: "CZK"),
        MockCurrency(currencyCode: "DKK"),
        MockCurrency(currencyCode: "EUR"),
        MockCurrency(currencyCode: "GBP"),
        MockCurrency(currencyCode: "HKD"),
        MockCurrency(currencyCode: "HRK"),
        MockCurrency(currencyCode: "HUF"),
        MockCurrency(currencyCode: "IDR"),
        MockCurrency(currencyCode: "ILS"),
        MockCurrency(currencyCode: "INR"),
        MockCurrency(currencyCode: "ISK"),
        MockCurrency(currencyCode: "JPY"),
        MockCurrency(currencyCode: "KRW"),
        MockCurrency(currencyCode: "KWD"),
        MockCurrency(currencyCode: "MAD"),
        MockCurrency(currencyCode: "MXN"),
        MockCurrency(currencyCode: "MYR"),
        MockCurrency(currencyCode: "NGN"),
        MockCurrency(currencyCode: "NOK"),
        MockCurrency(currencyCode: "NZD"),
        MockCurrency(currencyCode: "OMR"),
        MockCurrency(currencyCode: "PEN"),
        MockCurrency(currencyCode: "PHP"),
        MockCurrency(currencyCode: "PLN"),
        MockCurrency(currencyCode: "RON"),
        MockCurrency(currencyCode: "RUB"),
        MockCurrency(currencyCode: "SAR"),
        MockCurrency(currencyCode: "SEK"),
        MockCurrency(currencyCode: "SGD"),
        MockCurrency(currencyCode: "THB"),
        MockCurrency(currencyCode: "TRY"),
        MockCurrency(currencyCode: "TWD"),
        MockCurrency(currencyCode: "USD"),
        MockCurrency(currencyCode: "VND"),
        MockCurrency(currencyCode: "XAG"),
        MockCurrency(currencyCode: "XAU"),
        MockCurrency(currencyCode: "XPD"),
        MockCurrency(currencyCode: "XPT"),
        MockCurrency(currencyCode: "ZAR")
    ]
}
