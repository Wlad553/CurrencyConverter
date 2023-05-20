//
//  CurrencyConverterCoreDataTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 18/05/2023.
//

import XCTest
import CoreData
@testable import Currency_Converter

final class CurrencyConverterCoreDataTests: XCTestCase {
    var coreDataManager: CoreDataManager!
    var networkManager: NetworkCurrenciesDataManager!
    var derivedContext: NSManagedObjectContext!
    var currencyParsedData: [CurrencyRatesParsedData]!
    var currencyRatesSavedObjects: [CurrencySavedData]!

    override func setUp() {
        super.setUp()
        coreDataManager = TestCoreDataManager()
        derivedContext = coreDataManager.appMainContext
        networkManager = TestNetworkCurrenciesDataManager(coreDataManager: coreDataManager)
        
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

        do {
            try await derivedContext.perform { [self] in
                try coreDataManager.save(currencyRatesData: currencyParsedData)
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }
        
        await fulfillment(of: [saveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedObjects, "Objects shouldn't be nil")
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsCount)
    }
    
    func testUpdateCurrencySavedDataObjects() async {
        let firstSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesDataSecond", withExtension: "json")!
        let data = try! Data(contentsOf: dataUrl)
        let currencyParsedDataInitial: [CurrencyRatesParsedData]! = try? networkManager.parseJSON(withRatesData: data)
        XCTAssertNotNil(currencyParsedDataInitial)
        
        // 1. Save initial data
        do {
            try await derivedContext.perform { [self] in
                try coreDataManager.save(currencyRatesData: currencyParsedDataInitial)
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }
        
        await fulfillment(of: [firstSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedObjects, "Objects shouldn't be nil")
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsCount)
        for object in currencyRatesSavedObjects {
            guard let parsedSingleCurrencyRate = currencyParsedDataInitial.first(where: { parsedData in
                parsedData.quoteCurrency.currencyCode == object.quoteCurrency
            }) else {
                XCTFail("Object quote currency should have match with currencyParsedDataInitial")
                return
            }
            XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.currencyCode, object.quoteCurrency)
        }
        
        // 2. Update initial data with new data
        let secondSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)

        do {
            try await derivedContext.perform { [self] in
                try coreDataManager.addOrUpdateCurrencyRatesSavedDataObjects(with: currencyParsedData)
            }
        } catch {
            XCTFail("\(error.localizedDescription): updateCurrencySavedDataObjects should not throw")
        }
        
        await fulfillment(of: [secondSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsCount)
        for object in currencyRatesSavedObjects {
            guard let parsedSingleCurrencyRate = currencyParsedData.first(where: { parsedData in
                parsedData.quoteCurrency.currencyCode == object.quoteCurrency
            }) else {
                XCTFail("Object quote currency should have match with currencyParsedData")
                return
            }
            XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.currencyCode, object.quoteCurrency)
        }
    }
    
    func testDeleteObjects() async {
        let firstSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        
        // 1. Save data
        do {
            try await derivedContext.perform { [self] in
                try coreDataManager.save(currencyRatesData: currencyParsedData)
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }

        await fulfillment(of: [firstSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, Currency.availableCurrencyPairsCount)
        
        // 2. Delete saved data
        coreDataManager.deleteObjects(from: coreDataManager.currencySavedDataFetchRequest)
        let secondSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        do {
            try await derivedContext.perform { [self] in
                try derivedContext.save()
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }
        await fulfillment(of: [secondSaveExpectation], timeout: 2)
        
        currencyRatesSavedObjects = try? derivedContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedObjects)
        XCTAssertEqual(currencyRatesSavedObjects.count, 0)
    }
    
    func testSaveFavouriteCurrency() async {
        let saveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: derivedContext)
        var favouriteCurrenciesObjects: [FavouriteCurrency]! = try? derivedContext.fetch(coreDataManager.favouriteCurrencyFetchRequest)
        XCTAssertEqual(favouriteCurrenciesObjects.count, 0)
        
        do {
            try await derivedContext.perform { [self] in
                try coreDataManager.saveFavouriteCurrency(withCode: "USD")
                try coreDataManager.saveFavouriteCurrency(withCode: "EUR")
                try coreDataManager.saveFavouriteCurrency(withCode: "PLN")
            }
        } catch {
            XCTFail("\(error.localizedDescription): save should not throw")
        }
        await fulfillment(of: [saveExpectation], timeout: 2)
        
        favouriteCurrenciesObjects = try? derivedContext.fetch(coreDataManager.favouriteCurrencyFetchRequest)
        XCTAssertNotNil(favouriteCurrenciesObjects)
        XCTAssertEqual(favouriteCurrenciesObjects.count, 3)
    }
}

