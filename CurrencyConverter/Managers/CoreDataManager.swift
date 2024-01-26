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

public class CoreDataManager {
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
    
    // MARK: Logger
    private let logger = Logger()
    
    // MARK: - Objects deleting support
    func deleteObjects<T: NSManagedObject>(from request: NSFetchRequest<T>) where T: NSFetchRequestResult {
        guard let objects = try? appMainContext.fetch(request) else { return }
        objects.forEach { object in
            appMainContext.delete(object)
        }
    }
    
    // MARK: - Favorite currencies saving support
    func getFavouriteCurrencies() -> [Currency] {
        let userDefaults = UserDefaults.standard
        guard let favoriteCurrencies = favoriteCurrencies, userDefaults.bool(forKey: "isAppAlreadyLauchedOnce")
        else {
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
        deleteObjects(from: FavoriteCurrency.fetchRequest())
        newCurrenciesList.forEach { currency in
            saveFavoriteCurrency(currency: currency)
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
