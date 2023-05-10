//
//  CurrencyNetworkManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import UIKit

enum CurrencyAPIError: Error {
    case network
    case parsing
    case request
    case dataSaving
}

protocol CurrenciesDataNetworkManagerProtocol {
    static var urlSession: URLSession { get }
    func fetchCurrencyData( urlSession: URLSession, completionHandler: @escaping (Error?) -> Void)
    func parseJSON(withData data: Data) throws -> [CurrencyParsedData]?
    func fetchDataIfNeeded(completionHandler: @escaping (_ errorTitle: String?, _ errorMessage: String?) -> Void)
}

final class CurrenciesDataNetworkManager: CurrenciesDataNetworkManagerProtocol {
    static let urlSession = URLSession(configuration: .default)
    
    private let coreDataManager = CoreDataManager()
    private let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=\(Currency.availableCurrencyPairs)&api_key=\(apiKey)"
    
    func fetchCurrencyData( urlSession: URLSession = urlSession,
                            completionHandler: @escaping (Error?) -> Void = { _ in }) {
        guard let url = URL(string: urlString) else { return }
        urlSession.configuration.waitsForConnectivity = true
        urlSession.dataTask(with: url) { [self] data, response, error in
            do {
                if let error = error {
                    throw error
                }
                guard let _ = response else {
                    throw CurrencyAPIError.network
                }
                guard let data = data,
                      let currencyParsedData = try? parseJSON(withData: data)
                else {
                    throw CurrencyAPIError.parsing
                }
                guard let currencyDataObjects = try? coreDataManager.context.fetch(coreDataManager.currencySavedDataFetchRequest) else {
                    throw CoreDataError.objectsFetchingError
                }
                
                // if there are no new currencies after in currencyParsedData, then we just update their properties
                if currencyDataObjects.count == Currency.availableCurrencyPairsCount &&
                    currencyDataObjects.allSatisfy({ currency in
                        guard let quoteCurrency = currency.quoteCurrency else { return false }
                        return Currency.availableCurrenciesDict.keys.contains(quoteCurrency)
                    }) {
                    coreDataManager.updateCurrencySavedDataObjectsInContext(withData: currencyParsedData)
                    // In other case we delete all objects from container and add new ones
                } else {
                    coreDataManager.deleteObjects(from: coreDataManager.currencySavedDataFetchRequest)
                    coreDataManager.save(currencyRatesData: currencyParsedData)
                }
                
                do {
                    try coreDataManager.context.save()
                } catch {
                    throw CurrencyAPIError.dataSaving
                }
                DispatchQueue.main.async {
                    completionHandler(nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
            }
        }.resume()
    }
    
    func parseJSON(withData data: Data) throws -> [CurrencyParsedData]? {
        let decoder = JSONDecoder()
        let currencyData = try decoder.decode(CurrenciesData.self, from: data)
        
        var multipleCurrenciesParsedData: [CurrencyParsedData] = []
        for quote in 0..<currencyData.quotes.count{
            guard let singleCurrencyData = CurrencyParsedData(currencyData: currencyData, currencyNumber: quote) else { continue }
            multipleCurrenciesParsedData.append(singleCurrencyData)
        }
        return multipleCurrenciesParsedData
    }
    
    func fetchDataIfNeeded(completionHandler: @escaping (_ errorTitle: String?, _ errorMessage: String?) -> Void) {
        guard let objects = try? coreDataManager.context.fetch(coreDataManager.currencySavedDataFetchRequest) else { return }
        // Try to fetch data when the container is empty and we have no data stored or if containter has less objects than we get from server
        if objects.count != Currency.availableCurrencyPairsCount || objects.count == 0 {
            fetchCurrencyData { error in
                let errorTitle = self.getTitleAndMessageFor(error: error).title
                let errorMessage = self.getTitleAndMessageFor(error: error).message
                completionHandler(errorTitle, errorMessage)
            }
            return
        }
        // Or when it's been one or more hours since last update
        let timeIntervalsDifference = Date().timeIntervalSince1970 - objects.first!.timeIntervalSinceLastUpdate
        if timeIntervalsDifference >= (60 * 60) {
            fetchCurrencyData { error in
                let errorTitle = self.getTitleAndMessageFor(error: error).title
                let errorMessage = self.getTitleAndMessageFor(error: error).message
                completionHandler(errorTitle, errorMessage)
            }
            return
        }
        completionHandler(nil, nil)
    }
    
    private func getTitleAndMessageFor(error: Error?) -> (title: String?, message: String?) {
        var errorTitle: String?
        var errorMessage: String?
        
        if let error = error {
            
            switch error {
            case CurrencyAPIError.parsing:
                errorMessage = "Unable to process data"
            case CurrencyAPIError.dataSaving:
                errorMessage = "Unable to save rates"
            case CurrencyAPIError.network:
                errorTitle = "Unable to get latest rates"
                errorMessage = "Please, try again later"
            default: break
            }
        }
        return (errorTitle, errorMessage)
    }
}
