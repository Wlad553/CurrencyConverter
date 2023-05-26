//
//  TestCurrenciesDataNetworkManager.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 18/05/2023.
//

import Currency_Converter

final class TestNetworkCurrenciesDataManager: NetworkCurrenciesDataManager {
    convenience init() {
        let coreDataManager = TestCoreDataManager()
        self.init(coreDataManager: coreDataManager)
    }
}
