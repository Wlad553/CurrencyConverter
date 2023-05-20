//
//  CurrencyConverterAPICallTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 16/05/2023.
//

import XCTest
import CoreData
@testable import Currency_Converter

final class CurrencyConverterAPICallTests: XCTestCase {
    var networkManager: NetworkCurrenciesDataManager!
    var urlSession: URLSession!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURL.self]
        
        urlSession = URLSession.init(configuration: configuration)
        networkManager = TestNetworkCurrenciesDataManager()
    }
    
    override func tearDown() {
        urlSession = nil
        networkManager = nil
        super.tearDown()
    }
    
    func testCurrencyRatesAPISuccessfulResponse() {
        let expectation = expectation(description: "Wait for data to be fetched")
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let apiURL = URL(string: networkManager.urlString)!
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! Data(contentsOf: dataUrl)
            return (response, data)
        }
        
        networkManager.fetchCurrencyRatesData(urlSession: urlSession) { currencyRatesParsedData, error in
            XCTAssertNotNil(currencyRatesParsedData)
            XCTAssertNotNil(currencyRatesParsedData?.first)
            XCTAssertNotNil(currencyRatesParsedData?.last)
            
            let firstCurrencyPair = currencyRatesParsedData!.first!
            let lastCurrencyPair = currencyRatesParsedData!.last!
            
            XCTAssertEqual(firstCurrencyPair.askPrice, 231.1219)
            XCTAssertEqual(firstCurrencyPair.bidPrice, 231.1219)
            XCTAssertEqual(firstCurrencyPair.quoteCurrency.currencyCode, "ARS")
            XCTAssertEqual(firstCurrencyPair.baseCurrency.currencyCode, "USD")
            
            XCTAssertEqual(lastCurrencyPair.askPrice, 0.30706)
            XCTAssertEqual(lastCurrencyPair.bidPrice, 0.30706)
            XCTAssertEqual(lastCurrencyPair.quoteCurrency.currencyCode, "KWD")
            XCTAssertEqual(lastCurrencyPair.baseCurrency.currencyCode, "USD")
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
    
    func testFetchDataIfNeeded() async {
        let coreDataManager = networkManager.coreDataManager
        let dataFetchExpectation = expectation(description: "Wait for data to be downloaded")
        let dataSaveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataManager.appMainContext)
        var currencyRatesSavedDataObjects: [CurrencySavedData]!
        
        // 1. Save data if currencyRatesSavedDataObjects.count == 0
        let dataUrlInitial = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let dataInitial = try! Data(contentsOf: dataUrlInitial)
        var currencyParsedDataInitial: [CurrencyRatesParsedData]! = try? networkManager.parseJSON(withRatesData: dataInitial)
        
        let apiURL = URL(string: networkManager.urlString)!
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dataInitial)
        }
        
        networkManager.fetchDataIfNeeded (urlSession: urlSession) { errorTitle, errorMessage in
            XCTAssertNil(errorTitle)
            XCTAssertNil(errorMessage)
            dataFetchExpectation.fulfill()
        }
        await fulfillment(of: [dataFetchExpectation, dataSaveExpectation], timeout: 2)
        
        currencyRatesSavedDataObjects = try? coreDataManager.appMainContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedDataObjects)
        XCTAssertEqual(currencyRatesSavedDataObjects.count, Currency.availableCurrencyPairsCount)
        for object in currencyRatesSavedDataObjects {
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
        
        // 2. Update currencyRatesSavedDataObjects if currencyRatesSavedDataObjects already exist and minTimeIntervalDifferenceForUpdate is exceeded
        let dataFetchExpectationLast = expectation(description: "Wait for data to be downloaded")
        let dataSaveExpectationLast = expectation(forNotification: .NSManagedObjectContextDidSave, object: coreDataManager.appMainContext)
        
        let dataUrlLast = Bundle.main.url(forResource: "stubbedRatesDataSecond", withExtension: "json")!
        let dataLast = try! Data(contentsOf: dataUrlLast)
        let currencyParsedDataLast: [CurrencyRatesParsedData]! = try? networkManager.parseJSON(withRatesData: dataLast)
        
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dataLast)
        }

        networkManager.fetchDataIfNeeded (urlSession: urlSession, minTimeIntervalDifferenceForUpdate: 0) { errorTitle, errorMessage in
            XCTAssertNil(errorTitle)
            XCTAssertNil(errorMessage)
            dataFetchExpectationLast.fulfill()
        }
        await fulfillment(of: [dataFetchExpectationLast, dataSaveExpectationLast], timeout: 2)
        
        currencyRatesSavedDataObjects = try? coreDataManager.appMainContext.fetch(coreDataManager.currencySavedDataFetchRequest)
        XCTAssertNotNil(currencyRatesSavedDataObjects)
        XCTAssertEqual(currencyRatesSavedDataObjects.count, Currency.availableCurrencyPairsCount)
        for object in currencyRatesSavedDataObjects {
            guard let parsedSingleCurrencyRate = currencyParsedDataLast.first(where: { parsedData in
                parsedData.quoteCurrency.currencyCode == object.quoteCurrency
            }) else {
                XCTFail("Object quoteCurrency should have match with currencyParsedDataLast")
                return
            }
            XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
            XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.currencyCode, object.quoteCurrency)
        }
    }
}
