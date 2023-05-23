//
//  SearchControllerManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 09/05/2023.
//

import Foundation

final class SearchControllerManager {
    func filteredResultsWith<T: CurrencyProtocol>(_ searchText: String, setToFilter: Set<T>) -> [T] {
        var searchResult: [T] = []
        var alphanumericsSearchText = searchText
        alphanumericsSearchText.removeAll { character in
            let alphanumericsAndWhitespaceCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " "))
            return alphanumericsAndWhitespaceCharacterSet.isDisjoint(with: CharacterSet(charactersIn: "\(character)"))
        }
        
        if alphanumericsSearchText.isEmpty {
            searchResult.removeAll()
            return searchResult
        }
        
        var searchWordsToCheck = alphanumericsSearchText.lowercased().components(separatedBy: " ")
        searchWordsToCheck.removeAll { string in
            string.isEmpty
        }
        searchResult = setToFilter.filter({ currency in
            let currencyNameAndCodeWords = [currency.currencyCode.lowercased()] + currency.fullCurrencyName.lowercased().components(separatedBy: " ")
            var matchesCount = 0
            for searchWord in searchWordsToCheck {
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
        })
        
        searchResult.sort {
            return $0.currencyCode < $1.currencyCode
        }
        return searchResult
    }
}
