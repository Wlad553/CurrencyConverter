//
//  TestNetworkRatesDataManager.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/02/2024.
//

import CurrencyConverter
import Foundation

final class TestNetworkRatesDataManager: NetworkRatesDataManager {
    override init() {
        super.init()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURL.self]
        urlSession = URLSession.init(configuration: configuration)
    }
}
