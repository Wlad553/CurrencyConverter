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
    case dataSaving
}

final class CurrenciesDataNetworkManager {
    static let shared = CurrenciesDataNetworkManager()
    static let urlSession = URLSession(configuration: .default)
    
    private let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=\(Currency.availableCurrencyPairs)&api_key=\(apiKey)"
    
    private var fetchRequest: NSFetchRequest<CurrencySavedData> {
        CurrencySavedData.fetchRequest()
    }
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private init() {}

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
                guard let entity = NSEntityDescription.entity(forEntityName: "CurrencyData", in: context),
                      let currencyDataObjects = try? context.fetch(fetchRequest)
                else { return }
                
                // if there are no new currencies after in currencyParsedData, then we just update their properties
                if currencyDataObjects.count == Currency.availableCurrencyPairsCount &&
                    currencyDataObjects.allSatisfy({ currency in
                    guard let quoteCurrency = currency.quoteCurrency else { return false }
                    return Currency.availableCurrenciesDict.keys.contains(quoteCurrency)
                }) {
                    updateObjectsFromContext(withData: currencyParsedData)
                    // In other case we delete all objects from container and add new ones
                } else {
                    deleteObjectsFromContext()
                    
                    for singleCurrencyData in currencyParsedData {
                        let currencyDataObject = CurrencySavedData(entity: entity, insertInto: context)
                        currencyDataObject.quoteCurrency = singleCurrencyData.quoteCurrency.currencyCode
                        currencyDataObject.bidPrice = singleCurrencyData.bidPrice
                        currencyDataObject.askPrice = singleCurrencyData.askPrice
                        currencyDataObject.timeIntervalSinceLastUpdate = Date().timeIntervalSince1970
                    }
                }
                do {
                    try context.save()
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
    
    func fetchDataIfNeeded(completionHandler: @escaping (Error?) -> Void) {
        guard let objects = try? context.fetch(fetchRequest) else { return }
        // Try to fetch data when the container is empty and we have no data stored
        if objects.count != Currency.availableCurrencyPairsCount || objects.count == 0 {
            fetchCurrencyData { error in
                completionHandler(error)
            }
            return
        }
        // Or when it's been one or more hours since last update
        let timeIntervalsDifference = Date().timeIntervalSince1970 - objects.first!.timeIntervalSinceLastUpdate
        if timeIntervalsDifference >= (60 * 60) {
            fetchCurrencyData { error in
                completionHandler(error)
            }
            return
        }
        completionHandler(nil)
    }
    
    private func updateObjectsFromContext(withData currencyParsedData: [CurrencyParsedData]) {
        guard let objects = try? context.fetch(fetchRequest) else { return }
        for object in objects {
            let newCurrencyData = currencyParsedData.first { currencyParsedData in
                currencyParsedData.quoteCurrency.currencyCode == object.quoteCurrency
            }
            guard let newCurrencyData = newCurrencyData else { continue }
            object.askPrice = newCurrencyData.askPrice
            object.bidPrice = newCurrencyData.bidPrice
            object.timeIntervalSinceLastUpdate = Date().timeIntervalSince1970
        }
    }
    
    private func deleteObjectsFromContext() {
        guard let objects = try? context.fetch(fetchRequest) else { return }
        for object in objects {
            context.delete(object)
        }
    }
}
