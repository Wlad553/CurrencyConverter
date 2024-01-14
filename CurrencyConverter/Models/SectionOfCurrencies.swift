//
//  SectionOfCurrencies.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Differentiator

struct SectionOfCurrencies {
    var items: [Item]
    
    static func sectionsOfCurrenciesSorted() -> [SectionOfCurrencies] {
        var alphabeticallySorted2DArray = [SectionOfCurrencies(items: [])]
        var section = 0
        for currency in Currency.availableCurrencies() {
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

extension SectionOfCurrencies: SectionModelType {
    typealias Item = Currency

    init(original: SectionOfCurrencies, items: [Item]) {
        self = original
        self.items = items
    }
}

