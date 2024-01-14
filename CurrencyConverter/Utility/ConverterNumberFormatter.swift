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
        roundingMode = .down
        locale = .current
        groupingSeparator = String()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func applyFormat(previousText: String, currentText: String) -> String {
        let formatter = ConverterNumberFormatter()
        guard let newTextLast = currentText.last else { return currentText }
        
        if !previousText.isEmpty &&
            String(newTextLast) == formatter.decimalSeparator &&
            currentText.components(separatedBy: formatter.decimalSeparator).count < 3 &&
            previousText.components(separatedBy: formatter.decimalSeparator).count < 2 {
            return currentText
        }
        
        if let number = formatter.number(from: currentText),
           let formattedText = formatter.string(from: number),
           let textBeforeDecimalSeparator = formattedText.components(separatedBy: formatter.decimalSeparator)[safe: 0],
           textBeforeDecimalSeparator.count <= 12 {
            if currentText.isValidWith(regex: RegexPattern.exactZero(separator: formatter.decimalSeparator)) {
                return formattedText + formatter.decimalSeparator + String(0)
                
            } else if currentText.isValidWith(regex: RegexPattern.twoToThreeZeros(separator: formatter.decimalSeparator)) {
                return formattedText + formatter.decimalSeparator + String(0) + String(0)
                
            } else if currentText.isValidWith(regex: RegexPattern.zeroAtEnd(separator: formatter.decimalSeparator)) {
                return formattedText + String(0)
                
            } else  {
                return formattedText
            }
        }
        return currentText.isEmpty ? currentText : previousText
    }
}
