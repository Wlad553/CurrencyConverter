//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 22/04/2023.
//

import UIKit

class AddCurrencyTableVC: UITableViewController {
    let searchController = UISearchController()
    var currenciesArray = Currency.availableCurrenciesArray
    
    var sortedCurrencies2DArray: [[Currency]] {
        let alphabeticallySortedCurrenciesArray = currenciesArray.sorted {
            $0.isoCurrencyCode < $1.isoCurrencyCode
        }
        var alphabeticallySorted2DArray: [[Currency]] = [[]]
        var section = 0
        for currency in alphabeticallySortedCurrenciesArray {
            if alphabeticallySorted2DArray[section].isEmpty {
                alphabeticallySorted2DArray[section].append(currency)
            } else if  alphabeticallySorted2DArray[section].first?.isoCurrencyCode.first == currency.isoCurrencyCode.first {
                alphabeticallySorted2DArray[section].append(currency)
            } else {
                section += 1
                alphabeticallySorted2DArray.append([])
                alphabeticallySorted2DArray[section].append(currency)
            }
        }
        return alphabeticallySorted2DArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(barAction(sender:)))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sortedCurrencies2DArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sortedCurrencies2DArray[section].first?.isoCurrencyCode.first?.uppercased()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedCurrencies2DArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCurrencyCell", for: indexPath)
        let currency = sortedCurrencies2DArray[indexPath.section][indexPath.row]
        var content = cell.defaultContentConfiguration()
        
        content.text = "\(currency.isoCurrencyCode) - \(currency.fullCurrencyName)"
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goBack", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let destinationVC = segue.destination as? MainViewController,
              let senderIndexPath = sender as? IndexPath
        else { return }
        destinationVC.favouriteCurrenciesArray.append(sortedCurrencies2DArray[senderIndexPath.section][senderIndexPath.row])
    }
    
    @objc func barAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.searchTextField.clearButtonMode = .never
        searchController.searchBar.searchTextField.font = UIFont(name: "Lato-Regular", size: 17)
    }
}

extension AddCurrencyTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
}
