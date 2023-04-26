//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 22/04/2023.
//

import UIKit

class AddCurrencyTableVC: UITableViewController {
    let searchController = UISearchController()
    let noSearchResultsLabel = UILabel()
    let noSearchResultsStackView = UIStackView()
    
    var searchResultCurrencies: [Currency] = []
    var sortedCurrencies2DArray: [[Currency]] = []
    var currenciesArray = Currency.availableCurrenciesArray {
        didSet {
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
            sortedCurrencies2DArray = alphabeticallySorted2DArray
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchController()
        setUpNoSearchResultsStackView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(barAction(sender:)))
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            return 1
        }
            return sortedCurrencies2DArray.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
            return sortedCurrencies2DArray[section].first?.isoCurrencyCode.first?.uppercased()
        }
        if !searchResultCurrencies.isEmpty {
            return "Top results"
        }
            return nil
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            return searchResultCurrencies.count
        }
        return sortedCurrencies2DArray[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCurrencyCell", for: indexPath)
        var currency: Currency
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            currency = searchResultCurrencies[indexPath.row]
        } else {
            currency = sortedCurrencies2DArray[indexPath.section][indexPath.row]
        }
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
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            destinationVC.favouriteCurrenciesArray.append(searchResultCurrencies[senderIndexPath.row])
        } else {
            destinationVC.favouriteCurrenciesArray.append(sortedCurrencies2DArray[senderIndexPath.section][senderIndexPath.row])
        }
    }
    
    @objc func barAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.searchTextField.font = UIFont(name: "Lato-Regular", size: 17)
    }
    
    private func setUpNoSearchResultsStackView() {
        let noSearchResultsSublabel = UILabel()
        let noSearchResultsImage = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        
        noSearchResultsImage.contentMode = .scaleAspectFit
        noSearchResultsImage.tintColor = .systemGray
        
        noSearchResultsLabel.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        noSearchResultsLabel.numberOfLines = 0
        noSearchResultsLabel.textAlignment = .center
        
        noSearchResultsSublabel.font = UIFont.systemFont(ofSize: 14)
        noSearchResultsSublabel.textColor = noSearchResultsImage.tintColor
        noSearchResultsSublabel.text = "Check the spelling or try a new search"
        
        [noSearchResultsImage, noSearchResultsLabel, noSearchResultsSublabel].forEach { view in
            noSearchResultsStackView.addArrangedSubview(view)
        }
        noSearchResultsStackView.isHidden = true
        noSearchResultsStackView.axis = .vertical
        noSearchResultsStackView.spacing = 8
        noSearchResultsStackView.distribution = .equalSpacing
        noSearchResultsStackView.alignment = .center

        noSearchResultsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noSearchResultsStackView)
        NSLayoutConstraint.activate([
            noSearchResultsImage.heightAnchor.constraint(equalToConstant: 64),
            noSearchResultsImage.widthAnchor.constraint(equalToConstant: 48),
            
            noSearchResultsStackView.topAnchor.constraint(equalTo: view.topAnchor,constant: view.frame.height * 0.1),
            noSearchResultsStackView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 32),
            noSearchResultsStackView.trailingAnchor.constraint(greaterThanOrEqualTo: view.trailingAnchor, constant: -32),
            noSearchResultsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension AddCurrencyTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        if searchText.isEmpty {
            noSearchResultsStackView.isHidden = true
            tableView.reloadData()
            return
        }
        searchResultCurrencies = currenciesArray.filter({ currency in
            if "\(currency.isoCurrencyCode) \(currency.fullCurrencyName)".lowercased().contains(searchText.lowercased()) {
                return true
            }
            return false
        })
        if searchResultCurrencies.isEmpty {
            noSearchResultsStackView.isHidden = false
            noSearchResultsLabel.text = #"No results for "\#(searchText)""#
        } else {
            noSearchResultsStackView.isHidden = true
        }
        tableView.reloadData()
    }
}
