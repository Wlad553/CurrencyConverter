//
//  TestCoreDataManager.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/02/2024.
//

import CurrencyConverter
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
