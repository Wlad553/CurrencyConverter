//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation

public protocol CurrencyProtocol {
    var code: String { get }
    var localizedName: String { get }
}

enum Currency: String, CaseIterable, CurrencyProtocol {
    enum Price {
        case bid
        case ask
    }
    
    case aed
    case aoa
    case ars
    case aud
    case bgn
    case bhd
    case brl
    case cad
    case chf
    case clp
    case cny
    case cnh
    case cop
    case czk
    case dkk
    case eur
    case gbp
    case hkd
    case hrk
    case huf
    case idr
    case ils
    case inr
    case isk
    case jpy
    case krw
    case kwd
    case mad
    case mxn
    case myr
    case ngn
    case nok
    case nzd
    case omr
    case pen
    case php
    case pln
    case ron
    case rub
    case sar
    case sek
    case sgd
    case thb
    case `try`
    case twd
    case usd
    case vnd
    case xag
    case xau
    case xpd
    case xpt
    case zar
    
    var code: String {
        rawValue.uppercased()
    }
    
    var localizedName: String {
        NSLocalizedString(code, comment: "Localized name")
    }
    
    // minus 1 since we don't have such a pair like USD/USD
    static let availableCurrencyPairsNumer = allCases.count - 1
    
    static func availableCurrencies() -> [Currency] {
        return allCases.sorted { $0.code < $1.code }
    }
    
    static func availableCurrencyPairs() -> String {
        var string = String()
        allCases.forEach { currency in
            guard currency.code != "USD" else { return }
            string.append("USD\(currency.code),")
        }
        string.removeLast()
        return string
    }
}

// MARK: - Array of Currency
extension Array<Currency> {
    func alphabeticallyGroupedSections() -> [SectionOfCurrencies] {
        var alphabeticallySorted2DArray = [SectionOfCurrencies(items: [])]
        var section = 0
        self.forEach { currency in
            if alphabeticallySorted2DArray[section].items.isEmpty ||
                alphabeticallySorted2DArray[section].items.first?.code.first == currency.code.first {
                alphabeticallySorted2DArray[section].items.append(currency)
            } else {
                section += 1
                alphabeticallySorted2DArray.append(SectionOfCurrencies(items: .init()))
                alphabeticallySorted2DArray[section].items.append(currency)
            }
        }
        return alphabeticallySorted2DArray
    }
}
