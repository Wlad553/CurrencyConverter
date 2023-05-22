//
//  AddCurrencyTableViewControllerTest.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 21/05/2023.
//

import XCTest
@testable import Currency_Converter

final class AddCurrencyTableViewControllerTest: XCTestCase {
    var viewController: AddCurrencyTableViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "addCurrency") as? AddCurrencyTableViewController
        viewController.loadView()
        viewController.viewDidLoad()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testFilterResultsWith() {
        // 1.
        let filterResultFirst = viewController.searchControllerManager.filteredResultsWith("c c",
                                                                                           setToFilter: viewController.currenciesSet)
        let expectationArrayFirst: [Currency] = [
            Currency(currencyCode: "CAD")!,
            Currency(currencyCode: "CHF")!,
            Currency(currencyCode: "CLP")!,
            Currency(currencyCode: "CNH")!,
            Currency(currencyCode: "CNY")!,
            Currency(currencyCode: "COP")!,
            Currency(currencyCode: "CZK")!,
            Currency(currencyCode: "HRK")!
        ]
        XCTAssertEqual(filterResultFirst, expectationArrayFirst)
        
        // 2.
        let filterResultSecond = viewController.searchControllerManager.filteredResultsWith("c o y",
                                                                                            setToFilter: viewController.currenciesSet)
        let expectationArraySecond: [Currency] = [
            Currency(currencyCode: "CNH")!,
            Currency(currencyCode: "CNY")!
        ]
        XCTAssertEqual(filterResultSecond, expectationArraySecond)
        
        // 3.
        let filterResultThird = viewController.searchControllerManager.filteredResultsWith("....",
                                                                                           setToFilter: viewController.currenciesSet)
        let expectationArrayThird: [Currency] = []
        XCTAssertEqual(filterResultThird, expectationArrayThird)
        
        // 4.
        let filterResultFourth = viewController.searchControllerManager.filteredResultsWith("….a a….#*&$U#($D",
                                                                                            setToFilter: viewController.currenciesSet)
        let expectationArrayFourth: [Currency] = [Currency(currencyCode: "AUD")!]
        XCTAssertEqual(filterResultFourth, expectationArrayFourth)
        
        // 5.
        let filterResultFifth = viewController.searchControllerManager.filteredResultsWith("KW#*$* $#",
                                                                                           setToFilter: viewController.currenciesSet)
        let expectationArrayFifth: [Currency] = [
            Currency(currencyCode: "AOA")!,
            Currency(currencyCode: "KWD")!
        ]
        XCTAssertEqual(filterResultFifth, expectationArrayFifth)
        
        // 6.
        let filterResultSixth = viewController.searchControllerManager.filteredResultsWith("KW#*$* $#3",
                                                                                           setToFilter: viewController.currenciesSet)
        let expectationArraySixth: [Currency] = []
        XCTAssertEqual(filterResultSixth, expectationArraySixth)
    }
    
    func testUpdateSearchResults() {
        viewController.searchController.searchBar.text = "sw"
        viewController.updateSearchResults(for: viewController.searchController)
        let expectationArray: [Currency] = [Currency(currencyCode: "CHF")!,
                                            Currency(currencyCode: "SEK")!]
        XCTAssertEqual(viewController.searchResultCurrencies, expectationArray)
    }
}
