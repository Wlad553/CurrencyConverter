//
//  SearchControllerManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 09/05/2023.
//

import Foundation

final class SearchControllerManager {
    func filteredResultsWith<T: CurrencyProtocol>(_ searchText: String, arrayToFilter: [T]) -> [T] {
        var searchResult: [T] = []
        var alphanumericsSearchText = searchText
        alphanumericsSearchText.removeAll { character in
            let alphanumericsAndWhitespaceCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: Characters.whitespace))
            return alphanumericsAndWhitespaceCharacterSet.isDisjoint(with: CharacterSet(charactersIn: String(character)))
        }
        
        if alphanumericsSearchText.isEmpty {
            searchResult.removeAll()
            return searchResult
        }
        
        var searchWordsToCheck = alphanumericsSearchText.lowercased().components(separatedBy: Characters.whitespace)
        searchWordsToCheck.removeAll { string in
            string.isEmpty
        }
        
        searchResult = arrayToFilter.filter { currency in
            let currencyNameAndCodeWords = [currency.code.lowercased()] + currency.localizedName.lowercased().components(separatedBy: Characters.whitespace)
            var matchesCount = 0
            searchWordsToCheck.forEach { searchWord in
                for currencyString in currencyNameAndCodeWords {
                    if currencyString.hasPrefix(searchWord) {
                        matchesCount += 1
                        break
                    }
                }
            }
            if matchesCount == searchWordsToCheck.count {
                return true
            }
            return false
        }
        
        searchResult.sort {
            return $0.code < $1.code
        }
        
        return searchResult
    }
}
