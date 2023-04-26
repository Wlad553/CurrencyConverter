//
//  CurrencyNetworkManager.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 26/04/2023.
//

import UIKit

enum CurrencyAPIResponseError: Error {
    case network
    case parsing
    case request
}

class CurrencyNetworkManager {
    let urlString = "https://marketdata.tradermade.com/api/v1/live?currency=USDEUR&api_key=\(apiKey)"
    var onCompletion: (([CurrencyParsedData]) -> Void)?
    var dataFetchingFailed: ((Error) -> Void)?

    func fetchWeatherData(urlSession: URLSession = URLSession(configuration: .default)) {
        guard let url = URL(string: urlString) else { return }
        urlSession.configuration.waitsForConnectivity = true
        urlSession.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            do {
                if let error = error {
                    throw error
                }
                guard let _ = response else {
                    throw CurrencyAPIResponseError.network
                }
                guard let data = data,
                      let currencyParsedData = try? self.parseJSON(withData: data)
                else {
                    throw CurrencyAPIResponseError.parsing
                }
                self.onCompletion?(currencyParsedData)
            } catch {
                dataFetchingFailed?(error)
            }
        }.resume()
    }

    func parseJSON(withData data: Data) throws -> [CurrencyParsedData]? {
        let decoder = JSONDecoder()
        let currencyData = try decoder.decode(CurrenciesData.self, from: data)
        
        var multipleCurrenciesParsedData: [CurrencyParsedData] = []
        for i in 0..<currencyData.quotes.count{
            guard let singleCurrencyData = CurrencyParsedData(currencyData: currencyData, currencyNumber: i) else { continue }
            multipleCurrenciesParsedData.append(singleCurrencyData)
        }
        return multipleCurrenciesParsedData
    }
}
