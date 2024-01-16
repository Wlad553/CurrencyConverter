//
//  SectionOfCurrencies.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Differentiator

struct SectionOfCurrencies {
    var items: [Item]
}

extension SectionOfCurrencies: SectionModelType {
    typealias Item = Currency

    init(original: SectionOfCurrencies, items: [Item]) {
        self = original
        self.items = items
    }
}

