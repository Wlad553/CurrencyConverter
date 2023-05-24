//
//  CurrencyNetworkManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import UIKit
import CoreData

enum CurrencyAPIError: Error {
    case network
    case parsing
    case request
}

protocol NetworkCurrenciesDataManagerProtocol {
    static var urlSession: URLSession { get }
    var urlString: String { get }
    func fetchCurrencyRatesData(urlSession: URLSession, completionHandler: @escaping ([CurrencyRatesParsedData]?, Error?) -> Void)
    func parseJSON(withRatesData data: Data) throws -> [CurrencyRatesParsedData]?
    func fetchDataIfNeeded(urlSession: URLSession, completionHandler: @escaping (_ errorTitle: String?, _ errorMessage: String?) -> Void)
}

open class NetworkCurrenciesDataManager: NetworkCurrenciesDataManagerProtocol {
    public static var urlSession = URLSession(configuration: .default)
    
    let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=\(Currency.availableCurrencyPairs)&api_key=\(apiKey)"
    let coreDataManager: CoreDataManager
    
    public init(coreDataManager: CoreDataManager) {
        self.coreDataManager = coreDataManager
    }
    
    func fetchCurrencyRatesData(urlSession: URLSession = urlSession,
                                     completionHandler: @escaping ([CurrencyRatesParsedData]?, Error?) -> Void = { _, _  in }) {
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
                      let currencyRatesParsedData = try? parseJSON(withRatesData: data)
                else {
                    throw CurrencyAPIError.parsing
                }
                
                try coreDataManager.addOrUpdateCurrencyRatesSavedDataObjects(with: currencyRatesParsedData)
                
                DispatchQueue.main.async {
                    completionHandler(currencyRatesParsedData, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
            }
        }.resume()
    }
    
    func fetchCurrencyRatesData(urlSession: URLSession) {
        guard let url = URL(string: urlString) else { return }
        urlSession.configuration.waitsForConnectivity = true
        let dataTask = urlSession.dataTask(with: url)
        dataTask.resume()
    }
    
    public func parseJSON(withRatesData data: Data) throws -> [CurrencyRatesParsedData]? {
        let decoder = JSONDecoder()
        let currencyRatesData = try decoder.decode(CurrencyRatesData.self, from: data)
        
        var currencyRatesParsedData: [CurrencyRatesParsedData] = []
        for quote in 0..<currencyRatesData.quotes.count{
            guard let CurrencyPairRatesData = CurrencyRatesParsedData(currencyRatesData: currencyRatesData, currencyNumber: quote) else { continue }
            currencyRatesParsedData.append(CurrencyPairRatesData)
        }
        return currencyRatesParsedData
    }
    
    func fetchDataIfNeeded(urlSession: URLSession = urlSession,
                                completionHandler: @escaping (_ errorTitle: String?, _ errorMessage: String?) -> Void) {
        guard let objects = try? coreDataManager.appMainContext.fetch(coreDataManager.currencySavedDataFetchRequest) else { return }
        // Try to fetch data when the container is empty and we have no data stored or if containter has less objects than we get from server
        if objects.count != Currency.availableCurrencyPairsCount || objects.count == 0 {
            fetchCurrencyRatesData (urlSession: urlSession) { _, error in
                let errorTitle = self.getTitleAndMessageFor(error: error).title
                let errorMessage = self.getTitleAndMessageFor(error: error).message
                completionHandler(errorTitle, errorMessage)
            }
            return
        }
        // Or when it's been one or more hours since last update
        let timeIntervalsDifference = Date().timeIntervalSince1970 - objects.first!.timeIntervalSinceLastUpdate
        if timeIntervalsDifference >= (60 * 60) {
            fetchCurrencyRatesData (urlSession: urlSession) { _, error in
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
            case CoreDataError.objectsSaving:
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
