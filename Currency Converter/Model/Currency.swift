//
//  File.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 24/04/2023.
//

import Foundation

struct Currency: Equatable {
    let isoCurrencyCode: String
    let fullCurrencyName: String
    
    static let availableCurrenciesArray = [
        Currency(isoCurrencyCode: "AED", fullCurrencyName: "UAE Dirham"),
        Currency(isoCurrencyCode: "AOA", fullCurrencyName: "Angolan Kwanza"),
        Currency(isoCurrencyCode: "ARS", fullCurrencyName: "Argentine Peso"),
        Currency(isoCurrencyCode: "AUD", fullCurrencyName: "Australian Dollar"),
        Currency(isoCurrencyCode: "BGN", fullCurrencyName: "Bulgaria Lev"),
        Currency(isoCurrencyCode: "BHD", fullCurrencyName: "Bahraini Dinar"),
        Currency(isoCurrencyCode: "BRL", fullCurrencyName: "Brazilian Real"),
        Currency(isoCurrencyCode: "CAD", fullCurrencyName: "Canadian Dollar"),
        Currency(isoCurrencyCode: "CHF", fullCurrencyName: "Swiss Franc"),
        Currency(isoCurrencyCode: "CLP", fullCurrencyName: "Chilean Peso"),
        Currency(isoCurrencyCode: "CNY", fullCurrencyName: "Chinese Yuan onshore"),
        Currency(isoCurrencyCode: "CNH", fullCurrencyName: "Chinese Yuan offshore"),
        Currency(isoCurrencyCode: "COP", fullCurrencyName: "Colombian Peso"),
        Currency(isoCurrencyCode: "CZK", fullCurrencyName: "Czech Koruna"),
        Currency(isoCurrencyCode: "DKK", fullCurrencyName: "Danish Krone"),
        Currency(isoCurrencyCode: "EUR", fullCurrencyName: "Euro"),
        Currency(isoCurrencyCode: "GBP", fullCurrencyName: "British Pound Sterling"),
        Currency(isoCurrencyCode: "HKD", fullCurrencyName: "Hong Kong Dollar"),
        Currency(isoCurrencyCode: "HRK", fullCurrencyName: "Croatian Kuna"),
        Currency(isoCurrencyCode: "HUF", fullCurrencyName: "Hungarian Forint"),
        Currency(isoCurrencyCode: "IDR", fullCurrencyName: "Indonesian Rupiah"),
        Currency(isoCurrencyCode: "ILS", fullCurrencyName: "Israeli New Sheqel"),
        Currency(isoCurrencyCode: "INR", fullCurrencyName: "Indian Rupee"),
        Currency(isoCurrencyCode: "ISK", fullCurrencyName: "Icelandic Krona"),
        Currency(isoCurrencyCode: "JPY", fullCurrencyName: "Japanese Yen"),
        Currency(isoCurrencyCode: "KRW", fullCurrencyName: "South Korean Won"),
        Currency(isoCurrencyCode: "KWD", fullCurrencyName: "Kuwaiti Dinar"),
        Currency(isoCurrencyCode: "MAD", fullCurrencyName: "Moroccan Dirham"),
        Currency(isoCurrencyCode: "MXN", fullCurrencyName: "Mexican Peso"),
        Currency(isoCurrencyCode: "MYR", fullCurrencyName: "Malaysian Ringgit"),
        Currency(isoCurrencyCode: "NGN", fullCurrencyName: "Nigerean Naira"),
        Currency(isoCurrencyCode: "NOK", fullCurrencyName: "Norwegian Krone"),
        Currency(isoCurrencyCode: "NZD", fullCurrencyName: "New Zealand Dollar"),
        Currency(isoCurrencyCode: "OMR", fullCurrencyName: "Omani Rial"),
        Currency(isoCurrencyCode: "PEN", fullCurrencyName: "Peruvian Nuevo Sol"),
        Currency(isoCurrencyCode: "PHP", fullCurrencyName: "Philippine Peso"),
        Currency(isoCurrencyCode: "PLN", fullCurrencyName: "Polish Zloty"),
        Currency(isoCurrencyCode: "RON", fullCurrencyName: "Romanian Leu"),
        Currency(isoCurrencyCode: "RUB", fullCurrencyName: "Russian Ruble"),
        Currency(isoCurrencyCode: "SAR", fullCurrencyName: "Saudi Arabian Riyal"),
        Currency(isoCurrencyCode: "SEK", fullCurrencyName: "Swedish Krona"),
        Currency(isoCurrencyCode: "SGD", fullCurrencyName: "Singapore Dollar"),
        Currency(isoCurrencyCode: "THB", fullCurrencyName: "Thai Baht"),
        Currency(isoCurrencyCode: "TRY", fullCurrencyName: "Turkish Lira"),
        Currency(isoCurrencyCode: "TWD", fullCurrencyName: "Taiwanese Dollar"),
        Currency(isoCurrencyCode: "USD", fullCurrencyName: "US Dollar"),
        Currency(isoCurrencyCode: "VND", fullCurrencyName: "Vietnamese Dong"),
        Currency(isoCurrencyCode: "XAG", fullCurrencyName: "Silver (troy ounce)"),
        Currency(isoCurrencyCode: "XAU", fullCurrencyName: "Gold (troy ounce)"),
        Currency(isoCurrencyCode: "XPD", fullCurrencyName: "Palladium"),
        Currency(isoCurrencyCode: "XPT", fullCurrencyName: "Platinum"),
        Currency(isoCurrencyCode: "ZAR", fullCurrencyName: "South African Rand")
    ]
}
