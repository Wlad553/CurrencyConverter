//
//  CurrencyArray.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 17/01/2024.
//

import Foundation

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
