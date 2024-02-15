//
//  CoreDataManagerTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/02/2024.
//

import XCTest
import CoreData
@testable import CurrencyConverter

final class CoreDataManagerTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var networkManager: NetworkRatesDataManagerProtocol!
    var derivedContext: NSManagedObjectContext!
    var currencyParsedData: [CurrencyRateData]!
    var currencyRatesSavedObjects: [CurrencyRateSavedData]!

    override func setUp() {
        super.setUp()
        coreDataManager = TestCoreDataManager()
        derivedContext = coreDataManager.appMainContext
        networkManager = TestNetworkRatesDataManager()
        
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let data = try! Data(contentsOf: dataUrl)
        currencyParsedData = try! networkManager.parseJSON(withRatesData: data)
    }

    override func tearDown() {
        currencyRatesSavedObjects = nil
        networkManager = nil
        derivedContext = nil
        coreDataManager = nil
        currencyParsedData = nil
        super.tearDown()
    }
    
    func testSaveCurrencyRatesData() async {
        let saveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        
        await derivedContext.perform { [self] in
            coreDataManager.saveCurrencyRatesData(data: currencyParsedData)
        }
        
        await fulfillment(of: [saveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(CurrencyRateSavedData.fetchRequest())
        XCTAssertNotNil(currencyRatesSavedObjects, "Objects shouldn't be nil")
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsNumber)
    }
    
    func testUpdateCurrencySavedDataObjects() async {
        let firstSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesDataSecond", withExtension: "json")!
        let data = try! Data(contentsOf: dataUrl)
        let currencyParsedDataInitial: [CurrencyRateData]! = try? networkManager.parseJSON(withRatesData: data)
        XCTAssertNotNil(currencyParsedDataInitial)
        
        // 1. Save initial data
        await derivedContext.perform { [self] in
            coreDataManager.saveCurrencyRatesData(data: currencyParsedDataInitial)
        }
        
        await fulfillment(of: [firstSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(CurrencyRateSavedData.fetchRequest())
        XCTAssertNotNil(currencyRatesSavedObjects, "Objects shouldn't be nil")
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsNumber)
        for object in currencyRatesSavedObjects {
            guard let parsedSingleCurrencyRate = currencyParsedDataInitial.first(where: { parsedData in
                parsedData.quoteCurrency.code == object.quoteCurrency
            }) else {
                XCTFail("Object quote currency should have match with currencyParsedDataInitial")
                return
            }
            XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.code, object.quoteCurrency)
        }
        
        // 2. Update initial data with new data
        let secondSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)

        await derivedContext.perform { [self] in
            coreDataManager.updateCurrencyRatesSavedDataObjects(with: currencyParsedData)
        }
        
        await fulfillment(of: [secondSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(CurrencyRateSavedData.fetchRequest())
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsNumber)
        for object in currencyRatesSavedObjects {
            guard let parsedSingleCurrencyRate = currencyParsedData.first(where: { parsedData in
                parsedData.quoteCurrency.code == object.quoteCurrency
            }) else {
                XCTFail("Object quote currency should have match with currencyParsedData")
                return
            }
            XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.code, object.quoteCurrency)
        }
    }
    
    func testDeleteObjects() async {
        let firstSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        
        // 1. Save data
        await derivedContext.perform { [self] in
            coreDataManager.saveCurrencyRatesData(data: currencyParsedData)
        }

        await fulfillment(of: [firstSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(CurrencyRateSavedData.fetchRequest())
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsNumber)
        
        // 2. Delete saved data
        coreDataManager.deleteAllObjects(from: CurrencyRateSavedData.fetchRequest())
        let secondSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        do {
            try await derivedContext.perform { [self] in
                try derivedContext.save()
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }
        await fulfillment(of: [secondSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(CurrencyRateSavedData.fetchRequest())
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, 0)
    }
    
    func testSaveFavoriteCurrency() async {
        let saveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        var favouriteCurrenciesObjects: [FavoriteCurrency]! = try? derivedContext.fetch(FavoriteCurrency.fetchRequest())
        XCTAssertEqual(favouriteCurrenciesObjects.count, 0)
        
             await derivedContext.perform { [self] in
                coreDataManager.saveFavoriteCurrency(currency: .usd)
                coreDataManager.saveFavoriteCurrency(currency: .eur)
                coreDataManager.saveFavoriteCurrency(currency: .pln)
            }

        await fulfillment(of: [saveExpectation], timeout: 2)
        
        favouriteCurrenciesObjects = try? derivedContext.fetch(FavoriteCurrency.fetchRequest())
        XCTAssertNotNil(favouriteCurrenciesObjects)
        XCTAssertEqual(favouriteCurrenciesObjects.count, 3)
    }
}


