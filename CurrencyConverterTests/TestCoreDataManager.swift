//
//  TestCoreDataManager.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 16/05/2023.
//

import Currency_Converter
import CoreData

final class TestCoreDataManager: CoreDataManager {
    lazy var testPersistentContainer: NSPersistentContainer = {
        let persistentStoreDescription = NSPersistentStoreDescription()
        persistentStoreDescription.type = NSInMemoryStoreType
        
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.persistentStoreDescriptions = [persistentStoreDescription]
        
        container.loadPersistentStores { _, error in
            if let error = error as? NSError {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return container
    }()
    
    func newDerivedContext() -> NSManagedObjectContext {
        return testPersistentContainer.newBackgroundContext()
    }
    
    override init() {
        super.init()
        appMainContext = newDerivedContext()
    }
}
