//
//  CurrencyNetworkManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import UIKit
import CoreData

enum CurrencyAPIResponseError: Error {
    case network
    case parsing
    case request
}

class CurrenciesDataNetworkManager {
    static let shared = CurrenciesDataNetworkManager()
    static let urlSession = URLSession(configuration: .default)
    
    private let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=USDEUR,USDPLN&api_key=\(apiKey)"
    
    private var fetchRequest: NSFetchRequest<CurrencySavedData> {
        CurrencySavedData.fetchRequest()
    }
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    private init() {}

    func fetchCurrencyData(urlSession: URLSession = urlSession, completionHandler: @escaping () -> Void) {
        guard let url = URL(string: urlString) else { return }
        urlSession.configuration.waitsForConnectivity = true
        urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            do {
                if let error = error {
                    throw error
                }
                guard let _ = response else {
                    throw CurrencyAPIResponseError.network
                }
                guard let data = data,
                      let currencyParsedData = try? parseJSON(withData: data)
                else {
                    throw CurrencyAPIResponseError.parsing
                }
                guard let entity = NSEntityDescription.entity(forEntityName: "CurrencyData", in: context),
                      let currencyDataObjects = try? context.fetch(fetchRequest)
                else { return }
                
                if currencyDataObjects.count == Currency.availableCurrencyPairsCount &&
                    currencyDataObjects.allSatisfy({ currency in
                    guard let quoteCurrency = currency.quoteCurrency else { return false }
                    return Currency.availableCurrenciesDict.keys.contains(quoteCurrency)
                }) {
                    updateObjectsFromContext(withData: currencyParsedData)
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
                try context.save()
                DispatchQueue.main.async {
                    completionHandler()
                }
            } catch {
                print(error.localizedDescription)
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
    
    func fetchDataIfNeeded() {
        guard let objects = try? context.fetch(fetchRequest) else { return }
        if objects.count != Currency.availableCurrencyPairsCount || objects.count == 0 {
            fetchCurrencyData {}
            return
        }
        let timeIntervalsDifference = Date().timeIntervalSince1970 - objects.first!.timeIntervalSinceLastUpdate
        if timeIntervalsDifference >= (60 * 60) {
            fetchCurrencyData {}
        }
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
