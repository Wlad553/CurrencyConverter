//
//  CurrencyConverterUITests.swift
//  CurrencyConverterUITests
//
//  Created by Vladyslav Petrenko on 15/05/2023.
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
}
