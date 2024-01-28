//
//  CurrencyNetworkManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import UIKit
import RxSwift
import OSLog

enum CurrencyAPIError: Error {
    case network
    case parsing
    case request
    case wrongURL
}

protocol NetworkRatesDataManagerProtocol {
    var urlSession: URLSession { get }
    func fetchCurrencyRatesData() async throws -> [CurrencyRateData]
    func parseJSON(withRatesData data: Data) throws -> [CurrencyRateData]
    func fetchDataIfNeeded(savedRatesData: [CurrencyRateData]) async throws -> [CurrencyRateData]
}

open class NetworkRatesDataManager: NetworkRatesDataManagerProtocol {
    var urlSession = URLSession(configuration: .default)
    
    // MARK: - Data fetching
    func fetchCurrencyRatesData() async throws -> [CurrencyRateData] {
        guard let url = URL(string: CurrencyPriceAPI.urlString) else { throw CurrencyAPIError.wrongURL }
        urlSession.configuration.waitsForConnectivity = true
        do {
            let (data, response) = try await urlSession.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw CurrencyAPIError.network
            }
            
            do {
                return try parseJSON(withRatesData: data)
            } catch {
                throw error
            }
        } catch {
            throw error
        }
    }
    
    func fetchDataIfNeeded(savedRatesData: [CurrencyRateData]) async throws -> [CurrencyRateData] {
        // Try to fetch data if containter has less objects than we get from server
        if savedRatesData.count != Currency.availableCurrencyPairsNumber {
            return try await fetchCurrencyRatesData()
        }
        // Or when it's been one or more hours since last update
        let timeIntervalsDifference = Date().timeIntervalSince1970 - savedRatesData.first!.requestTimestamp
        if timeIntervalsDifference >= (60 * 60) {
            return try await fetchCurrencyRatesData()
        }
        
        return savedRatesData
    }
    
    func fetchCurrencyRatesData(urlSession: URLSession) {
        guard let url = URL(string: CurrencyPriceAPI.urlString) else { return }
        urlSession.configuration.waitsForConnectivity = true
        let dataTask = urlSession.dataTask(with: url)
        dataTask.resume()
    }
    
    // MARK: - Data parsing
    public func parseJSON(withRatesData data: Data) throws -> [CurrencyRateData] {
        let decoder = JSONDecoder()
        let currencyRatesData = try decoder.decode(CurrencyRatesRawData.self, from: data)
        var currencyRatesParsedData: [CurrencyRateData] = []
        
        for quote in (0..<currencyRatesData.quotes.count) {
            do {
                let CurrencyPairRatesData = try CurrencyRateData(currencyRatesRawData: currencyRatesData, index: quote)
                currencyRatesParsedData.append(CurrencyPairRatesData)
            } catch {
                throw error
            }
        }
        
        return currencyRatesParsedData
    }
}
