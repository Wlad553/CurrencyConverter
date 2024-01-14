//
//  Array+safeSubscript.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 13/01/2024.
//

import Foundation

extension Array {
    /// Safely extracts an element at the specified index.
        ///
        /// - Parameter index: The index of the element to be extracted.
        /// - Returns: The element at the specified index, or `nil` if the index is out of bounds.
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
