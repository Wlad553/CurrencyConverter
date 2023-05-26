//
//  Extesions.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 08/05/2023.
//

import UIKit

// MARK: Notification.Name
extension Notification.Name {
    static let curreniesDataFetched = Notification.Name("com.vladyslavpetrenko.currencyDataFetched")
}

// MARK: UIColor
extension UIColor {
    static let activeText = UIColor(red: 1/255, green: 35/255, blue: 83/255, alpha: 1)
    static let inactiveText = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
    static let activeTextFieldBorder = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let textFieldBackground = UIColor(red: 240/255, green: 241/255, blue: 245/255, alpha: 1)
    static let currencyLabel = UIColor(red: 1/255, green: 35/255, blue: 83/255, alpha: 1)
    static let blueButton = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let bottomEllipseLayer = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
    static let middleEllipseLayer = UIColor(red: 27/255, green: 134/255, blue: 249/255, alpha: 1)
    static let topEllipseLayer = UIColor(red: 51/255, green: 149/255, blue: 255/255, alpha: 1)
}
