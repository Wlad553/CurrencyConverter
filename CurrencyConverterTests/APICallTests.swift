//
//  APICallTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/02/2024.
//

import XCTest
import CoreData
@testable import CurrencyConverter

final class APICallTests: XCTestCase {
    var networkManager: NetworkRatesDataManagerProtocol!
    
    override func setUp() {
        super.setUp()
        networkManager = TestNetworkRatesDataManager()
    }
    
    override func tearDown() {
        networkManager = nil
        super.tearDown()
    }
    
    func testCurrencyRatesAPISuccessfulResponse() async {
        let expectation = expectation(description: "Wait for data to be fetched")
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let apiURL = URL(string: CurrencyPriceAPI.urlString)!
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! Data(contentsOf: dataUrl)
            return (response, data)
        }
        
        do {
            let currencyRatesParsedData = try await networkManager.fetchCurrencyRatesData()
            
            XCTAssertNotNil(currencyRatesParsedData)
            XCTAssertNotNil(currencyRatesParsedData.first)
            XCTAssertNotNil(currencyRatesParsedData.last)
            
            let firstCurrencyPair = currencyRatesParsedData.first!
            let lastCurrencyPair = currencyRatesParsedData.last!
            
            XCTAssertEqual(firstCurrencyPair.askPrice, 231.1219)
            XCTAssertEqual(firstCurrencyPair.bidPrice, 231.1219)
            XCTAssertEqual(firstCurrencyPair.quoteCurrency.code, "ARS")
            XCTAssertEqual(firstCurrencyPair.baseCurrency.code, "USD")
            XCTAssertEqual(firstCurrencyPair.requestTimestamp, 1684252586)
            
            XCTAssertEqual(lastCurrencyPair.askPrice, 0.30706)
            XCTAssertEqual(lastCurrencyPair.bidPrice, 0.30706)
            XCTAssertEqual(lastCurrencyPair.quoteCurrency.code, "KWD")
            XCTAssertEqual(lastCurrencyPair.baseCurrency.code, "USD")
            XCTAssertEqual(lastCurrencyPair.requestTimestamp, 1684252586)
            
            expectation.fulfill()
        } catch {
            XCTFail("\(error.localizedDescription): data fetching should not throw")
        }
        await fulfillment(of: [expectation], timeout: 2)
    }
    
    func testFetchDataIfNeeded() async {
        let dataFetchExpectation = expectation(description: "Wait for data to be downloaded")
        
        // 1. Save data if currencyRatesSavedDataObjects.count == 0
        let dataUrlInitial = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let dataInitial = try! Data(contentsOf: dataUrlInitial)
        let currencyParsedDataInitial: [CurrencyRateData]! = try? networkManager.parseJSON(withRatesData: dataInitial)
        
        let apiURL = URL(string: CurrencyPriceAPI.urlString)!
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dataInitial)
        }
        
        do {
            let currencyRatesParsedData = try await networkManager.fetchDataIfNeeded(savedRatesData: currencyParsedDataInitial)
            
            XCTAssertNotNil(currencyRatesParsedData)
            XCTAssertEqual(currencyRatesParsedData.count, Currency.availableCurrencyPairsNumber)
            
            for object in currencyRatesParsedData {
                guard let parsedSingleCurrencyRate = currencyParsedDataInitial.first(where: { parsedData in
                    parsedData.quoteCurrency.code == object.quoteCurrency.code
                }) else {
                    XCTFail("Object quote currency should have match with currencyParsedDataInitial")
                    return
                }
                XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
                XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
                XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.code, object.quoteCurrency.code)
                XCTAssertEqual(parsedSingleCurrencyRate.requestTimestamp, object.requestTimestamp)
            }
            
            dataFetchExpectation.fulfill()
        } catch {
            XCTFail("\(error.localizedDescription): data fetching should not throw")
        }
        
        await fulfillment(of: [dataFetchExpectation], timeout: 2)

        // 2. Update currencyRatesSavedDataObjects if currencyRatesSavedDataObjects already exist and minTimeIntervalDifferenceForUpdate is exceeded
        let dataFetchExpectationLast = expectation(description: "Wait for data to be downloaded")
        
        let dataUrlLast = Bundle.main.url(forResource: "stubbedRatesDataSecond", withExtension: "json")!
        let dataLast = try! Data(contentsOf: dataUrlLast)
        let currencyParsedDataLast: [CurrencyRateData]! = try? networkManager.parseJSON(withRatesData: dataLast)
        
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")

            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, dataLast)
        }

        do {
            let currencyRatesParsedData = try await networkManager.fetchDataIfNeeded(savedRatesData: currencyParsedDataLast)
            
            XCTAssertNotNil(currencyRatesParsedData)
            XCTAssertEqual(currencyRatesParsedData.count, Currency.availableCurrencyPairsNumber)
            
            for object in currencyRatesParsedData {
                guard let parsedSingleCurrencyRate = currencyParsedDataLast.first(where: { parsedData in
                    parsedData.quoteCurrency.code == object.quoteCurrency.code
                }) else {
                    XCTFail("Object quote currency should have match with currencyParsedDataInitial")
                    return
                }
                XCTAssertEqual(parsedSingleCurrencyRate.askPrice, object.askPrice)
                XCTAssertEqual(parsedSingleCurrencyRate.bidPrice, object.bidPrice)
                XCTAssertEqual(parsedSingleCurrencyRate.quoteCurrency.code, object.quoteCurrency.code)
                XCTAssertEqual(parsedSingleCurrencyRate.requestTimestamp, object.requestTimestamp)
            }
            
            dataFetchExpectationLast.fulfill()
        } catch {
            XCTFail("\(error.localizedDescription): data fetching should not throw")
        }
        
        await fulfillment(of: [dataFetchExpectationLast], timeout: 2)
    }
}
