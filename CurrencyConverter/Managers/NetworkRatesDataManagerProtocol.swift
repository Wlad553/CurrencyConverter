//
//  NetworkRatesDataManagerProtocol.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 15/02/2024.
//

import Foundation

protocol NetworkRatesDataManagerProtocol {
    var urlSession: URLSession { get set }
    func fetchCurrencyRatesData() async throws -> [CurrencyRateData]
    func fetchCurrencyRatesData(urlSession: URLSession)
    func parseJSON(withRatesData data: Data) throws -> [CurrencyRateData]
    func fetchDataIfNeeded(savedRatesData: [CurrencyRateData]) async throws -> [CurrencyRateData]
}
