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
    
    func testFilterNonEmptyResults() {
        // 1.
        let filterResultFirst = viewController.searchControllerManager.filteredResultsWith("c c",
                                                                                           setToFilter: MockCurrency.currenciesSet)
        let expectationArrayFirst: [MockCurrency] = [
            MockCurrency(currencyCode: "CAD"),
            MockCurrency(currencyCode: "CHF"),
            MockCurrency(currencyCode: "CLP"),
            MockCurrency(currencyCode: "CNH"),
            MockCurrency(currencyCode: "CNY"),
            MockCurrency(currencyCode: "COP"),
            MockCurrency(currencyCode: "CZK"),
            MockCurrency(currencyCode: "HRK")
        ]
        XCTAssertEqual(filterResultFirst, expectationArrayFirst)
        
        // 2.
        let filterResultSecond = viewController.searchControllerManager.filteredResultsWith("c o y",
                                                                                            setToFilter: MockCurrency.currenciesSet)
        let expectationArraySecond: [MockCurrency] = [
            MockCurrency(currencyCode: "CNH"),
            MockCurrency(currencyCode: "CNY")
        ]
        XCTAssertEqual(filterResultSecond, expectationArraySecond)
        
        // 3.
        let filterResultThird = viewController.searchControllerManager.filteredResultsWith("….a a….#*&$U#($D",
                                                                                            setToFilter: MockCurrency.currenciesSet)
        let expectationArrayThird: [MockCurrency] = [MockCurrency(currencyCode: "AUD")]
        XCTAssertEqual(filterResultThird, expectationArrayThird)
        
        // 4.
        let filterResultFourth = viewController.searchControllerManager.filteredResultsWith("KW#*$* $#",
                                                                                           setToFilter: MockCurrency.currenciesSet)
        let expectationArrayFourth: [MockCurrency] = [
            MockCurrency(currencyCode: "AOA"),
            MockCurrency(currencyCode: "KWD")
        ]
        XCTAssertEqual(filterResultFourth, expectationArrayFourth)
        
        // 5.
        let filterResultFifth = viewController.searchControllerManager.filteredResultsWith("sw",
                                                                                           setToFilter: MockCurrency.currenciesSet)
        let expectationArrayFifth: [MockCurrency] = [
            MockCurrency(currencyCode: "CHF"),
            MockCurrency(currencyCode: "SEK")
        ]
        XCTAssertEqual(filterResultFifth, expectationArrayFifth)
    }
    
    func testFilterEmptyResults() {
        // 1.
        let filterResultFirst = viewController.searchControllerManager.filteredResultsWith("KW#*$* $#3",
                                                                                           setToFilter: MockCurrency.currenciesSet)
        let expectationArrayFirst: [MockCurrency] = []
        XCTAssertEqual(filterResultFirst, expectationArrayFirst)
        
        // 2.
        let filterResultSecond = viewController.searchControllerManager.filteredResultsWith("....",
                                                                                           setToFilter: MockCurrency.currenciesSet)
        let expectationArraySecond: [MockCurrency] = []
        XCTAssertEqual(filterResultSecond, expectationArraySecond)
    }
}
