//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Vladyslav Petrenko on 15/05/2023.
//

import XCTest
@testable import Currency_Converter

final class CurrencyConverterTests: XCTestCase {
    
    var viewController: MainViewController!
    
    override func setUp() {
        super.setUp()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        viewController = storyboard.instantiateViewController(withIdentifier: "main") as? MainViewController
        viewController.loadView()
        viewController.viewDidLoad()
    }

    override func tearDown() {
        viewController = nil
        super.tearDown()
    }
}
