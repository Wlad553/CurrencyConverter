//
//  String+isValidWithRegex.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation

extension String {
    /**
     Determines if a string conforms to a specific regex pattern. It compiles the provided regex pattern and attempts to find a match within the entire string. If a match is found, it returns `true`; otherwise, it returns `false`.
     
     - Note: If the provided regex pattern is invalid, this method will also return `false`.
     */
    func isValidWith(regex: String) -> Bool {
        guard let gRegex = try? NSRegularExpression(pattern: regex) else { return false }
        let range = NSRange(location: 0, length: self.utf16.count)
        
        if gRegex.firstMatch(in: self, range: range) != nil {
            return true
        }
        
        return false
    }
}
