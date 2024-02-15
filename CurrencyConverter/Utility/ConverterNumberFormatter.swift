//
//  AccountingNumberFormatter.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation

final class ConverterNumberFormatter: NumberFormatter {
    override init() {
        super.init()
        numberStyle = .decimal
        maximumFractionDigits = 2
        locale = .current
        groupingSeparator = String()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func convertToString(double: Double) -> String {
        var returnString = string(from: NSNumber(value: double)) ?? String()
        groupingSeparator = nil
    
        if returnString.components(separatedBy: decimalSeparator).count == 1 {
            minimumFractionDigits = 1
        } else if returnString.components(separatedBy: decimalSeparator).count == 2 {
            minimumFractionDigits = 2
        }
        
        returnString = string(from: NSNumber(value: double)) ?? String()
        
        if double > 0 && double < 0.01 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            formatter.minimumFractionDigits = 20
            
            if let stringValue = formatter.string(from: NSNumber(value: double)),
               let firstGreaterThanZeroCharacterIndex = stringValue.firstIndex(where: { $0 > "0" }) {
                returnString = String(stringValue.prefix(through: firstGreaterThanZeroCharacterIndex))
            }
        }
        
        return returnString
    }
    
    func applyConvertingFormat(previousText: String, currentText: String) -> String {
        guard let number = number(from: currentText) else { return currentText.isEmpty ? currentText : previousText }
        if currentText.components(separatedBy: decimalSeparator).count > 2 {
            return previousText
        }
        
        if number.doubleValue < 0.01 {
            return currentText
        }
        if previousText == currentText {
            return string(from: number) ?? currentText
        } else {
            return currentText
        }
    }
}
