//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/05/2023.
//

import XCTest
@testable import Currency_Converter

final class MainViewControllerTests: XCTestCase {
    var viewController: MainViewController!
    
    override func setUp() {
        super.setUp()
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURL.self]
        NetworkCurrenciesDataManager.urlSession = URLSession.init(configuration: configuration)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "main") as? MainViewController
        viewController.loadView()
        viewController.coreDataManager = TestCoreDataManager()
        
        let dataUrl = Bundle.main.url(forResource: "stubbedRatesData", withExtension: "json")!
        let apiURL = URL(string: viewController.networkCurrenciesDataManager.urlString)!
        MockURL.requestHandler = { request in
            XCTAssertNotNil(request.url, "Request url should not be nil")
            XCTAssertEqual(request.url, apiURL, "Request url & apiURL must be equal")
            
            let response = HTTPURLResponse(url: apiURL, statusCode: 200, httpVersion: nil, headerFields: nil)!
            let data = try! Data(contentsOf: dataUrl)
            return (response, data)
        }
    }
    
    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
    
    func testTryUpdateLastTimeUpdatedLabel() {
        let saveExpectation = expectation(forNotification: .NSManagedObjectContextDidSave, object: viewController.coreDataManager.appMainContext)

        viewController.networkCurrenciesDataManager.fetchCurrencyRatesData { _, error in
            XCTAssertNil(error, "Error must be nil")
        }
        wait(for: [saveExpectation], timeout: 2)
        
        viewController.tryUpdateLastTimeUpdatedLabel(forTimeZone: TimeZone(identifier: "GMT")!)
        XCTAssertEqual(viewController.lastTimeUpdatedLabel.text, "16 May 2023 3:56 PM")
    }
    
    func testCheckMaskForTextField() {
        let textField = UITextField()
        
        // 1.
        textField.text = "1200.00.00"
        viewController.checkMaskForTextField(textField: textField)
        XCTAssertEqual(textField.text, "1200.00")
        
        // 2.
        textField.text = "......523526"
        viewController.checkMaskForTextField(textField: textField)
        XCTAssertEqual(textField.text, "0.52")
        
        // 3.
        textField.text = ",24,14"
        viewController.checkMaskForTextField(textField: textField)
        XCTAssertEqual(textField.text, "0.24")
        
        // 4.
        textField.text = "200,.05,"
        viewController.checkMaskForTextField(textField: textField)
        XCTAssertEqual(textField.text, "200.05")
    }
    
    func testConvertActiveTextFieldCurrencyToOtherCurrencies() {
        viewController.viewDidLoad()
        viewController.mainWindowView.tableView.reloadData()
        
        let saveExpectation = XCTestExpectation(description: "Waiting for fetched data to be saved to CoreData database")
        let saveResult = XCTWaiter.wait(for: [saveExpectation], timeout: 1.0)
        guard saveResult == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        let usdCell: MainTableViewCell! = viewController.cells.first { cell in
            cell.currencyLabel.text == "USD"
        }
        let eurCell: MainTableViewCell! = viewController.cells.first { cell in
            cell.currencyLabel.text == "EUR"
        }
        let plnCell: MainTableViewCell! = viewController.cells.first { cell in
            cell.currencyLabel.text == "PLN"
        }
        XCTAssertNotNil(usdCell)
        XCTAssertNotNil(eurCell)
        XCTAssertNotNil(plnCell)
        
        // 1.
        usdCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(usdCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "10000.00")
        XCTAssertEqual(eurCell.textField.text, "9205.22")
        XCTAssertEqual(plnCell.textField.text, "41318.30")
        
        // 2.
        eurCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(eurCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "10863.40")
        XCTAssertEqual(eurCell.textField.text, "10000.00")
        XCTAssertEqual(plnCell.textField.text, "44885.72")
        
        // 3.
        plnCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(plnCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "2420.24")
        XCTAssertEqual(eurCell.textField.text, "2227.88")
        XCTAssertEqual(plnCell.textField.text, "10000.00")
        
        // ask price test
        viewController.askButtonTapped()
        
        // 4.
        usdCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(usdCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "10000.00")
        XCTAssertEqual(eurCell.textField.text, "9205.22")
        XCTAssertEqual(plnCell.textField.text, "41327.30")
        
        // 5.
        eurCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(eurCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "10863.40")
        XCTAssertEqual(eurCell.textField.text, "10000.00")
        XCTAssertEqual(plnCell.textField.text, "44895.50")
        
        // 6.
        plnCell.textField.text = "10000.00"
        viewController.convertActiveTextFieldCurrencyToOtherCurrencies(plnCell.textField)
        
        XCTAssertEqual(usdCell.textField.text, "2419.71")
        XCTAssertEqual(eurCell.textField.text, "2227.39")
        XCTAssertEqual(plnCell.textField.text, "10000.00")
    }
    
    func testPriceEstimationButtonTapped() {
        viewController.viewDidLoad()
        let askButton = viewController.mainWindowView.askButton!
        let bidButton = viewController.mainWindowView.bidButton!
        XCTAssertNotNil(askButton)
        XCTAssertNotNil(bidButton)
        
        // initial state
        XCTAssertFalse(bidButton.isEnabled)
        XCTAssertTrue(askButton.isEnabled)
        XCTAssertEqual(bidButton.layer.backgroundColor, UIColor.blueButton.cgColor)
        XCTAssertEqual(askButton.layer.backgroundColor, UIColor.white.cgColor)
        
        // 1. ask button tapped
        viewController.askButtonTapped()
        
        let expectationAskButton = XCTestExpectation(description: "Waiting for animation to be ended")
        let resultAskButton = XCTWaiter.wait(for: [expectationAskButton], timeout: 0.5)
        guard resultAskButton == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        XCTAssertTrue(bidButton.isEnabled)
        XCTAssertFalse(askButton.isEnabled)
        XCTAssertEqual(bidButton.layer.backgroundColor, UIColor.white.cgColor)
        XCTAssertEqual(askButton.layer.backgroundColor, UIColor.blueButton.cgColor)
        
        // 2. bid button tapped
        viewController.bidButtonTapped()
        
        let expectationBidButton = XCTestExpectation(description: "Waiting for animation to be ended")
        let resultBidButton = XCTWaiter.wait(for: [expectationBidButton], timeout: 0.5)
        guard resultBidButton == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        XCTAssertFalse(bidButton.isEnabled)
        XCTAssertTrue(askButton.isEnabled)
        XCTAssertEqual(bidButton.layer.backgroundColor, UIColor.blueButton.cgColor)
        XCTAssertEqual(askButton.layer.backgroundColor, UIColor.white.cgColor)
    }
    
    func testPrepareCellsForEditingToggle() {
        viewController.viewDidLoad()
        viewController.mainWindowView.tableView.reloadData()
        
        let saveExpectation = XCTestExpectation(description: "Waiting for fetched data to be saved to CoreData database")
        let saveResult = XCTWaiter.wait(for: [saveExpectation], timeout: 0.5)
        guard saveResult == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        // initial state
        XCTAssertFalse(viewController.mainWindowView.tableView.isEditing)
        for cell in viewController.cells {
            XCTAssertEqual(cell.stackViewLeadingConstraint.constant, 32)
            XCTAssertEqual(cell.textFieldTrailingConstraint.constant, -32)
        }

        // first toggle
        viewController.prepareCellsForEditingToggle()
        let firstToggleExpectation = XCTestExpectation(description: "Waiting for animation to be ended")
        let firstToggleResult = XCTWaiter.wait(for: [firstToggleExpectation], timeout: 0.2)
        guard firstToggleResult == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        XCTAssertTrue(viewController.mainWindowView.tableView.isEditing)
        for cell in viewController.cells {
            XCTAssertEqual(cell.stackViewLeadingConstraint.constant, 56)
            XCTAssertEqual(cell.textFieldTrailingConstraint.constant, -56)
        }
        
        // second toggle
        viewController.prepareCellsForEditingToggle()
        let secondToggleExpectation = XCTestExpectation(description: "Waiting for animation to be ended")
        let secondToggleResult = XCTWaiter.wait(for: [secondToggleExpectation], timeout: 0.2)
        guard secondToggleResult == XCTWaiter.Result.timedOut else {
            XCTFail("Delay interrupted")
            return
        }
        
        XCTAssertFalse(viewController.mainWindowView.tableView.isEditing)
        for cell in viewController.cells {
            XCTAssertEqual(cell.stackViewLeadingConstraint.constant, 32)
            XCTAssertEqual(cell.textFieldTrailingConstraint.constant, -32)
        }
    }
}
