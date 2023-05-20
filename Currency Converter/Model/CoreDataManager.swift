//
//  CoreDataManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 10/05/2023.
//

import CoreData
import UIKit

enum CoreDataError: Error {
    case nonExistingEntity
    case objectsFetchingError
    case objectsSaving
}

open class CoreDataManager {
    lazy public var appMainContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var currencySavedDataFetchRequest: NSFetchRequest<CurrencySavedData> {
        CurrencySavedData.fetchRequest()
    }
    
    var favouriteCurrencyFetchRequest: NSFetchRequest<FavouriteCurrency> {
        FavouriteCurrency.fetchRequest()
    }
    
    public init() {}
    
    func save(currencyRatesData: [CurrencyRatesParsedData]) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "CurrencyData", in: appMainContext) else { return }
        for singleRateData in currencyRatesData {
            let currencyDataObject = CurrencySavedData(entity: entity, insertInto: appMainContext)
            currencyDataObject.quoteCurrency = singleRateData.quoteCurrency.currencyCode
            currencyDataObject.bidPrice = singleRateData.bidPrice
            currencyDataObject.askPrice = singleRateData.askPrice
            currencyDataObject.timeIntervalSinceLastUpdate = Date().timeIntervalSince1970
        }
        
        try appMainContext.save()
    }
    
    func deleteObjects<T: NSManagedObject>(from request: NSFetchRequest<T>) where T: NSFetchRequestResult {
        guard let objects = try? appMainContext.fetch(request) else { return }
        for object in objects {
            appMainContext.delete(object)
        }
    }
    
    func saveFavouriteCurrency(withCode currencyCode: String) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavouriteCurrency", in: appMainContext) else {
            throw CoreDataError.nonExistingEntity
        }
        guard let currency = Currency(currencyCode: currencyCode) else {
            throw CurrencyError.nonExistingCurrency
        }
        let currencyObject = FavouriteCurrency(entity: entity, insertInto: appMainContext)
        currencyObject.currencyCode = currency.currencyCode
        
        try appMainContext.save()
    }
    
    func getFavouriteCurrencies() throws -> [FavouriteCurrency] {
        let userDefaults = UserDefaults.standard
        // if user has ever launched the app, then favouriteCurrencies is retreived from container if he hasn't, then 3 standard currency will be added to favourites
        if !userDefaults.bool(forKey: "isAppAlreadyLauchedOnce") {
            userDefaults.set(true, forKey: "isAppAlreadyLauchedOnce")
            ["USD", "EUR", "PLN"].forEach { currencyCode in
                try? saveFavouriteCurrency(withCode: currencyCode)
            }
        }
        return try appMainContext.fetch(favouriteCurrencyFetchRequest)
    }
    
    func addOrUpdateCurrencyRatesSavedDataObjects(with currencyParsedData: [CurrencyRatesParsedData]) throws {
        guard let currencyRatesDataObjects = try? appMainContext.fetch(currencySavedDataFetchRequest) else {
            throw CoreDataError.objectsFetchingError
        }
        
        do {
            if currencyRatesDataObjects.count == Currency.availableCurrencyPairsCount &&
                currencyRatesDataObjects.allSatisfy({ currency in
                    guard let quoteCurrency = currency.quoteCurrency else { return false }
                    return Currency.availableCurrenciesDict.keys.contains(quoteCurrency)
                }) {
                try updateCurrencySavedDataObjects(withData: currencyParsedData)
                // In other case we delete all objects from container and add new ones
            } else {
                deleteObjects(from: currencySavedDataFetchRequest)
                try save(currencyRatesData: currencyParsedData)
            }
        } catch {
            throw CoreDataError.objectsSaving
        }
    }
    
    private func updateCurrencySavedDataObjects(withData currencyParsedData: [CurrencyRatesParsedData]) throws {
        guard let objects = try? appMainContext.fetch(currencySavedDataFetchRequest) else { return }
        let currentTimeIntervalSince1970 = Date().timeIntervalSince1970
        for object in objects {
            let newCurrencyData = currencyParsedData.first { currencyParsedData in
                currencyParsedData.quoteCurrency.currencyCode == object.quoteCurrency
            }
            guard let newCurrencyData = newCurrencyData else { continue }
            object.askPrice = newCurrencyData.askPrice
            object.bidPrice = newCurrencyData.bidPrice
            object.timeIntervalSinceLastUpdate = currentTimeIntervalSince1970
        }
        
        try appMainContext.save()
    }
}
