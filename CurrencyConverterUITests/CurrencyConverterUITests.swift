//
//  CurrencyConverterUITests.swift
//  CurrencyConverterUITests
//
//  Created by Vladyslav Petrenko on 12/01/2024.
//

import XCTest

final class CurrencyConverterUITests: XCTestCase {
    var app: XCUIApplication!
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    override func tearDown() {
        super.tearDown()
        app = nil
    }
    
    func testMainScreenElementsExistence() {
        XCTAssertTrue(app.otherElements["topViewWithThreeLayers"].exists)
        XCTAssertTrue(app.staticTexts["appNameLabel"].exists)
        XCTAssertTrue(app.buttons["askButton"].exists)
        XCTAssertTrue(app.buttons["bidButton"].exists)
        XCTAssertTrue(app.otherElements["windowView"].exists)
        XCTAssertTrue(app.buttons["addCurrencyButton"].exists)
        XCTAssertTrue(app.buttons["editButton"].exists)
        XCTAssertTrue(app.staticTexts["lastUpdatedLabel"].exists)
        XCTAssertTrue(app.staticTexts["lastUpdatedSublabel"].exists)
        XCTAssertTrue(app.tables["windowViewTableView"].exists)
        XCTAssertTrue(app.buttons["shareButton"].exists)
        
        let firstCell = app.tables["windowViewTableView"].cells.firstMatch
        XCTAssertTrue(firstCell.exists)
        XCTAssertTrue(firstCell.staticTexts["cellCurrencyLabel"].exists)
        XCTAssertTrue(firstCell.images["cellChevronImageView"].exists)
        XCTAssertTrue(firstCell.textFields["cellTextField"].exists)
    }
    
    func testMainScreenShareButton() {
        XCTAssertTrue(app.buttons["shareButton"].exists)
        
        app.buttons["shareButton"].tap()
        XCTAssertTrue(app.alerts.buttons["okAction"].exists)
        
        app.alerts.buttons["okAction"].tap()
        
        XCTAssertTrue(app.textFields["cellTextField"].exists)
        app.textFields["cellTextField"].firstMatch.tap()
        app.typeText("100")
        app.staticTexts["cellCurrencyLabel"].firstMatch.tap()
        
        app.buttons["shareButton"].tap()
        XCTAssertTrue(app.navigationBars["UIActivityContentView"].exists)
    }
    
    func testMoveRowsMainScreenTableView() {
        let firstCell = app.tables["windowViewTableView"].cells.firstMatch
        let firstCellLabelText = firstCell.staticTexts.firstMatch.label
        
        app.buttons["editButton"].tap()
        firstCell.buttons["Reorder \(firstCell.staticTexts.firstMatch.label)"].swipeDown()
        
        let newFirstCellLabelText = firstCell.staticTexts.firstMatch.label
        XCTAssertNotEqual(firstCellLabelText, newFirstCellLabelText)
    }
    
    func testDeleteAndAddCell() {
        let firstCell = app.tables["windowViewTableView"].cells.firstMatch
        let firstCellLabelText = firstCell.staticTexts.firstMatch.label
        
        XCTAssertTrue(app.staticTexts[firstCellLabelText].exists)
        firstCell.swipeLeft(velocity: .slow)
        firstCell.buttons.firstMatch.tap()
        XCTAssertFalse(app.staticTexts[firstCellLabelText].exists)
        
        app.buttons["addCurrencyButton"].tap()
        XCTAssertTrue(app.tables["currenciesListTableView"].exists)
        
        let addCurrencyScreenFirstCell = app.tables["currenciesListTableView"].cells.firstMatch
        let addCurrencyScreenFirstCurrencyLabelText = addCurrencyScreenFirstCell.staticTexts.firstMatch.label
        let addedCurrencyCode = String(addCurrencyScreenFirstCurrencyLabelText.prefix(3))
        addCurrencyScreenFirstCell.tap()
        
        XCTAssertFalse(app.tables["currenciesListTableView"].exists)
        XCTAssertTrue(app.staticTexts[addedCurrencyCode].exists)
    }
    
    func testAddCurrencyScreen() {
        app.buttons["addCurrencyButton"].tap()
        let tableView = app.tables["currenciesListTableView"]
        
        XCTAssertTrue(tableView.exists)
        XCTAssertTrue(app.searchFields["searchTextField"].exists)
        XCTAssertFalse(app.staticTexts["noSearchResultsLabel"].exists)
        XCTAssertFalse(app.staticTexts["noSearchResultsLabelSublabel"].exists)
        XCTAssertFalse(app.images["magnifyingGlass"].exists)
        
        app.searchFields["searchTextField"].tap()
        XCTAssertTrue(app.keyboards.firstMatch.exists)
        XCTAssertFalse(app.buttons["cancelButton"].exists)
        app.typeText("....")
        
        XCTAssertTrue(app.staticTexts["noSearchResultsLabel"].exists)
        XCTAssertTrue(app.staticTexts["noSearchResultsLabelSublabel"].exists)
        XCTAssertTrue(app.images["magnifyingGlass"].exists)
        XCTAssertFalse(app.tables["addCurrencyTableView"].cells.firstMatch.exists)
        
        app.keys["delete"].tap(withNumberOfTaps: 4, numberOfTouches: 1)
        app.typeText("c")
        
        XCTAssertTrue(tableView.cells.firstMatch.exists)
        XCTAssertFalse(app.staticTexts["noSearchResultsLabel"].exists)
        XCTAssertFalse(app.staticTexts["noSearchResultsLabelSublabel"].exists)
        XCTAssertFalse(app.images["magnifyingGlass"].exists)
        
        app.buttons["Cancel"].tap()
        XCTAssertFalse(app.keyboards.firstMatch.exists)
        
        app.buttons["cancelButton"].tap()
        XCTAssertFalse(tableView.exists)
        XCTAssertTrue(app.tables["windowViewTableView"].exists)
    }
}
