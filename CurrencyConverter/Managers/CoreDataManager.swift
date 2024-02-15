//
//  CoreDataManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 10/05/2023.
//

import CoreData
import OSLog
import UIKit

enum CoreDataError: Error {
    case nonExistingEntity
    case objectsFetching
    case objectsSaving
}

open class CoreDataManager {
    // MARK: AppMainContext
    lazy public var appMainContext: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    // MARK: - CoreData Objects
    private var favoriteCurrencies: [FavoriteCurrency]? {
        guard let favoriteCurrencies = try? appMainContext.fetch(FavoriteCurrency.fetchRequest()) else {
            logger.error("\(CoreDataError.objectsFetching.localizedDescription)")
            return nil
        }
        return favoriteCurrencies
    }
    
    private var currencyRatesSavedData: [CurrencyRateSavedData]? {
        guard let currencyRatesSavedData = try? appMainContext.fetch(CurrencyRateSavedData.fetchRequest()) else {
            logger.error("\(CoreDataError.objectsFetching.localizedDescription)")
            return nil
        }
        return currencyRatesSavedData
    }
    
    // MARK: Logger
    private let logger = Logger()
    
    // MARK: Init
    public init() {}
    
    // MARK: - Objects deleting support
    func deleteAllObjects<T: NSManagedObject>(from request: NSFetchRequest<T>) where T: NSFetchRequestResult {
        guard let objects = try? appMainContext.fetch(request) else { return }
        objects.forEach { object in
            appMainContext.delete(object)
        }
    }
    
    // MARK: - Favorite currencies saving support
    func getFavoriteCurrencies() -> [Currency] {
        let userDefaults = UserDefaults.standard
        guard let favoriteCurrencies = favoriteCurrencies, userDefaults.bool(forKey: "isAppAlreadyLauchedOnce") else {
            userDefaults.set(true, forKey: "isAppAlreadyLauchedOnce")
            [Currency.usd,
             Currency.eur,
             Currency.pln,].forEach { currency in
                saveFavoriteCurrency(currency: currency)
            }
            return [.usd, .eur, .pln]
        }
        
        var currencies: [Currency] = []
        favoriteCurrencies.forEach { favoriteCurrency in
            guard let currency = Currency(code: favoriteCurrency.code ?? String()) else {
                logger.error("\(CurrencyError.nonExistingCurrency.localizedDescription)")
                return
            }
            currencies.append(currency)
        }
        return currencies
    }
    
    func deleteFavoriteCurrency(currency: Currency) {
        guard let favoriteCurrencies = self.favoriteCurrencies else { return }
        favoriteCurrencies.forEach { favoriteCurrency in
            if favoriteCurrency.code == currency.code {
                appMainContext.delete(favoriteCurrency)
            }
        }
        
        saveContext()
    }
    
    func saveFavoriteCurrency(currency: Currency) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteCurrency", in: appMainContext) else {
            logger.error("\(CoreDataError.nonExistingEntity.localizedDescription)")
            return
        }
        guard let currency = Currency(code: currency.code) else {
            logger.error("\(CurrencyError.nonExistingCurrency.localizedDescription)")
            return
        }
        
        let currencyObject = FavoriteCurrency(entity: entity, insertInto: appMainContext)
        currencyObject.code = currency.code
        
        saveContext()
    }
    
    func moveFavoriteCurrency(newCurrenciesList: [Currency]) {
        deleteAllObjects(from: FavoriteCurrency.fetchRequest())
        newCurrenciesList.forEach { currency in
            saveFavoriteCurrency(currency: currency)
        }
    }
    
    // MARK: - Rates data saving support
    func getCurrencyRatesData() -> [CurrencyRateData] {
        guard let currencySavedRatesData = currencyRatesSavedData else { return [] }
        var currencyRatesData: [CurrencyRateData] = []
        
        currencySavedRatesData.forEach { currencySavedRateData in
            do {
                let currencyRateData = try CurrencyRateData(currencyRateSavedData: currencySavedRateData)
                currencyRatesData.append(currencyRateData)
            } catch {
                logger.error("\(error.localizedDescription)")
                return
            }
        }
        
        return currencyRatesData
    }
    
    private func saveCurrencyRatesData(data: [CurrencyRateData]) {
        guard let entity = NSEntityDescription.entity(forEntityName: "CurrencyRateSavedData", in: appMainContext) else { return }
        for singleRateData in data {
            let currencyDataObject = CurrencyRateSavedData(entity: entity, insertInto: appMainContext)
            currencyDataObject.quoteCurrency = singleRateData.quoteCurrency.code
            currencyDataObject.bidPrice = singleRateData.bidPrice
            currencyDataObject.askPrice = singleRateData.askPrice
            currencyDataObject.requestTimestamp = singleRateData.requestTimestamp
        }
        
        saveContext()
    }

    func updateCurrencyRatesSavedDataObjects(with currencyParsedData: [CurrencyRateData]) {
        guard let currencyRatesDataObjects = currencyRatesSavedData else { return }
        
        if currencyRatesDataObjects.count == Currency.availableCurrencyPairsNumber && currencyRatesDataObjects.allSatisfy({ currency in
                guard let quoteCurrency = Currency(code: currency.quoteCurrency ?? String()) else { return false }
                return Currency.availableCurrencies().contains(quoteCurrency)
            }) {
            
            currencyRatesDataObjects.forEach { object in
                let newCurrencyData = currencyParsedData.first { currencyParsedData in
                    currencyParsedData.quoteCurrency.code == object.quoteCurrency
                }
                if let newCurrencyData = newCurrencyData {
                    object.askPrice = newCurrencyData.askPrice
                    object.bidPrice = newCurrencyData.bidPrice
                    object.requestTimestamp = newCurrencyData.requestTimestamp
                }
            }
            
            saveContext()
        } else {
            deleteAllObjects(from: CurrencyRateSavedData.fetchRequest())
            saveCurrencyRatesData(data: currencyParsedData)
        }
    }
    
    // MARK: Context Saving Support
    private func saveContext() {
        guard appMainContext.hasChanges else { return }
        do {
            try appMainContext.save()
        } catch {
            let nserror = error as NSError
            logger.error("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
}
