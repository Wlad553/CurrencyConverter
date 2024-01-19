//
//  SectionOfCurrencies.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 14/01/2024.
//

import Differentiator
import Foundation

struct SectionOfCurrencies {
    var id = UUID()
    var items: [Item]
}

extension SectionOfCurrencies: AnimatableSectionModelType {
    typealias Identity = String
    typealias Item = Currency
    
    var identity: String {
        return id.uuidString
    }

    init(original: SectionOfCurrencies, items: [Item]) {
        self = original
        self.items = items
    }
    
    init() {
        self.items = []
    }
}

