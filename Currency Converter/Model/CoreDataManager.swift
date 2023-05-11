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

final class CoreDataManager {
    lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    var currencySavedDataFetchRequest: NSFetchRequest<CurrencySavedData> {
        CurrencySavedData.fetchRequest()
    }
    
    var favouriteCurrencyFetchRequest: NSFetchRequest<FavouriteCurrency> {
        FavouriteCurrency.fetchRequest()
    }
    
    func updateCurrencySavedDataObjectsInContext(withData currencyParsedData: [CurrencyParsedData]) {
        guard let objects = try? context.fetch(currencySavedDataFetchRequest) else { return }
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
    
    func save(currencyRatesData: [CurrencyParsedData]) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "CurrencyData", in: context) else { return }
        for singleRateData in currencyRatesData {
            let currencyDataObject = CurrencySavedData(entity: entity, insertInto: context)
            currencyDataObject.quoteCurrency = singleRateData.quoteCurrency.currencyCode
            currencyDataObject.bidPrice = singleRateData.bidPrice
            currencyDataObject.askPrice = singleRateData.askPrice
            currencyDataObject.timeIntervalSinceLastUpdate = Date().timeIntervalSince1970
        }
        
        try context.save()
    }
    
    func deleteObjects<T: NSManagedObject>(from request: NSFetchRequest<T>) where T: NSFetchRequestResult {
        guard let objects = try? context.fetch(request) else { return }
        for object in objects {
            context.delete(object)
        }
    }
    
    func saveFavouriteCurrency(withCode currencyCode: String) throws {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavouriteCurrency", in: context) else {
            throw CoreDataError.nonExistingEntity
        }
        guard let currency = Currency(currencyCode: currencyCode) else {
            throw CurrencyError.nonExistingCurrency
        }
        let currencyObject = FavouriteCurrency(entity: entity, insertInto: context)
        currencyObject.currencyCode = currency.currencyCode
        
        try context.save()
    }
    
    func getFavouriteCurrencies() throws -> [FavouriteCurrency] {
        let userDefaults = UserDefaults.standard
        let fetchRequest: NSFetchRequest<FavouriteCurrency> = FavouriteCurrency.fetchRequest()
        // if user has ever launched the app, then favouriteCurrencies is retreived from container if he hasn't, then 3 standard currency will be added to favourites
        if !userDefaults.bool(forKey: "isAppAlreadyLauchedOnce") {
            userDefaults.set(true, forKey: "isAppAlreadyLauchedOnce")
            ["USD", "EUR", "PLN"].forEach { currencyCode in
                try? saveFavouriteCurrency(withCode: currencyCode)
            }
        }
        return try context.fetch(fetchRequest)
    }
}
