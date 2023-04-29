//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 22/04/2023.
//

import UIKit

final class AddCurrencyTableVC: UITableViewController {
    let searchController = UISearchController()
    let noSearchResultsLabel = UILabel()
    let noSearchResultsStackView = UIStackView()
    var stackViewYAnchorConstraint: NSLayoutConstraint!
    
    var currenciesSet = Currency.availableCurrenciesSet
    var searchResultCurrencies: [Currency] = []
    var sortedCurrencies2DArray: [[Currency]] {
        let alphabeticallySortedCurrenciesArray = currenciesSet.sorted {
            $0.currencyCode < $1.currencyCode
        }
        var alphabeticallySorted2DArray: [[Currency]] = [[]]
        var section = 0
        for currency in alphabeticallySortedCurrenciesArray {
            if alphabeticallySorted2DArray[section].isEmpty {
                alphabeticallySorted2DArray[section].append(currency)
            } else if  alphabeticallySorted2DArray[section].first?.currencyCode.first == currency.currencyCode.first {
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
        setUpNoSearchResultsStackView()
        addNotificationCenterObservers()
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
            return sortedCurrencies2DArray[section].first?.currencyCode.first?.uppercased()
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
        
        content.text = "\(currency.currencyCode) - \(currency.fullCurrencyName)"
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
        let currencyToAdd: Currency
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            currencyToAdd = searchResultCurrencies[senderIndexPath.row]
        } else {
            currencyToAdd = sortedCurrencies2DArray[senderIndexPath.section][senderIndexPath.row]
        }
        destinationVC.saveFavouriteCurrency(currencyCode: currencyToAdd.currencyCode)
    }
    
    @objc func barAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @objc func keyboardNotificationTriggered(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let navigationBarHeight = navigationController?.navigationBar.frame.height
        else { return }
        if notification.name == UIResponder.keyboardWillShowNotification {
            self.stackViewYAnchorConstraint.constant = -keyboardFrame.height / 2.5 - navigationBarHeight
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            self.stackViewYAnchorConstraint.constant = 0
            UIView.animate(withDuration: 1) {
                self.view.layoutIfNeeded()
            }
        }
    }
    
    private func setUpSearchController() {
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.placeholder = "Search Currency"
        searchController.searchBar.searchTextField.font = UIFont(name: "Lato-Regular", size: 17)
    }
    
    private func setUpNoSearchResultsStackView() {
        let sublabel = UILabel()
        let imageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
                
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray
        
        noSearchResultsLabel.font = UIFont.systemFont(ofSize: 17, weight: .heavy)
        noSearchResultsLabel.numberOfLines = 0
        noSearchResultsLabel.textAlignment = .center
        
        sublabel.font = UIFont.systemFont(ofSize: 14)
        sublabel.textColor = imageView.tintColor
        sublabel.text = "Check the spelling or try a new search"
        
        [imageView, noSearchResultsLabel, sublabel].forEach { view in
            noSearchResultsStackView.addArrangedSubview(view)
        }
        noSearchResultsStackView.isHidden = true
        noSearchResultsStackView.axis = .vertical
        noSearchResultsStackView.spacing = 8
        noSearchResultsStackView.distribution = .equalSpacing
        noSearchResultsStackView.alignment = .center
        
        noSearchResultsStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noSearchResultsStackView)
        stackViewYAnchorConstraint = noSearchResultsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 48),
            
            stackViewYAnchorConstraint,
            noSearchResultsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func addNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotificationTriggered(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotificationTriggered(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
    }
}

extension AddCurrencyTableVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text,
              !searchText.isEmpty
        else {
            noSearchResultsStackView.isHidden = true
            tableView.reloadData()
            return
        }
        
        filterResultsWith(searchText)

        if searchResultCurrencies.isEmpty {
            noSearchResultsStackView.isHidden = false
            noSearchResultsLabel.text = #"No results for "\#(searchText)""#
        } else {
            noSearchResultsStackView.isHidden = true
        }
        tableView.reloadData()
    }
    
    private func filterResultsWith(_ searchText: String) {
        var alphanumericsSearchText = searchText
        alphanumericsSearchText.removeAll { character in
            let alphanumericsAndWhitespaceCharacterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: " "))
            return alphanumericsAndWhitespaceCharacterSet.isDisjoint(with: CharacterSet(charactersIn: "\(character)"))
        }
        
        if alphanumericsSearchText.isEmpty {
            searchResultCurrencies.removeAll()
            return
        }
        
        var searchWordsToCheck = alphanumericsSearchText.lowercased().components(separatedBy: " ")
        searchWordsToCheck.removeAll { string in
            string.isEmpty
        }
        searchResultCurrencies = currenciesSet.filter({ currency in
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
        
        searchResultCurrencies.sort {
            return $0.currencyCode < $1.currencyCode
        }
    }
}
