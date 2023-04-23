//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 22/04/2023.
//

import UIKit
import Speech

class AddCurrencyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    let searchController = UISearchController()
    
    var currencyArray: [[String]] = [
        [
            "AED - UAE Dirham",
            "AOA - Angolan Kwanza",
            "ARS - Argentine Peso",
            "AUD - Australian Dollar",
        ],
        [
            "BGN - Bulgaria Lev",
            "BHD - Bahraini Dinar",
            "BRL - Brazilian Real",
        ],
        [
            "CAD - Canadian Dollar",
            "CHF - Swiss Franc",
            "CLP - Chilean Peso",
            "CNY - Chinese Yuan onshore",
            "CNH - Chinese Yuan offshore",
            "COP - Colombian Peso",
            "CZK - Czech Koruna",
        ],
        [
            "DKK - Danish Krone",
        ],
        [
            "EUR - Euro",
        ],
        [
            "GBP - British Pound Sterling",
        ],
        [
            "HKD - Hong Kong Dollar",
            "HRK - Croatian Kuna",
            "HUF - Hungarian Forint",
        ],
        [
            "IDR - Indonesian Rupiah",
            "ILS - Israeli New Sheqel",
            "INR - Indian Rupee",
            "ISK - Icelandic Krona",
        ],
        [
            "JPY - Japanese Yen",
        ],
        [
            "KRW - South Korean Won",
            "KWD - Kuwaiti Dinar",
        ],
        [
            "MAD - Moroccan Dirham",
            "MXN - Mexican Peso",
            "MYR - Malaysian Ringgit",
        ],
        [
            "NGN - Nigerean Naira",
            "NOK - Norwegian Krone",
            "NZD - New Zealand Dollar",
        ],
        [
            "OMR - Omani Rial",
        ],
        [
            "PEN - Peruvian Nuevo Sol",
            "PHP - Philippine Peso",
            "PLN - Polish Zloty",
        ],
        [
            "RON - Romanian Leu",
            "RUB - Russian Ruble",
        ],
        [
            "SAR - Saudi Arabian Riyal",
            "SEK - Swedish Krona",
            "SGD - Singapore Dollar",
        ],
        [
            "THB - Thai Baht",
            "TRY - Turkish Lira",
            "TWD - Taiwanese Dollar",
        ],
        [
            "USD - US Dollar",
        ],
        [
            "VND - Vietnamese Dong",
        ],
        [
            "XAG - Silver (troy ounce)",
            "XAU - Gold (troy ounce)",
            "XPD - Palladium",
            "XPT - Platinum",
        ],
        [
            "ZAR - South African Rand"
        ]
    ]
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setUpSearchController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @objc func barAction(sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    private func setUpSearchController() {
        let textField = searchController.searchBar.value(forKey: "searchField") as? UITextField
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.automaticallyShowsCancelButton = true
        searchController.searchBar.searchTextField.clearButtonMode = .never
        searchController.searchBar.placeholder = "Search Currency"
                
        let dictButton = UIButton()
        dictButton.tintColor = textField?.leftView?.tintColor
        dictButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
//        searchController.searchBar.searchTextField.inputView = UIView()

        if #available(iOS 15.0, *) {
            guard dictButton.imageView != nil else { return }
            dictButton.configuration = UIButton.Configuration.plain()
            dictButton.configuration?.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(scale: .medium)
            dictButton.configuration?.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0)
            dictButton.imageView?.contentMode = .center
            dictButton.imageView?.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                dictButton.imageView!.widthAnchor.constraint(equalToConstant: 25)
            ])
        } else {
            dictButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: -5, bottom: 0, right: 0)
            NSLayoutConstraint.activate([
                dictButton.widthAnchor.constraint(equalToConstant: 30)
            ])
        }
        
        textField?.rightView = dictButton
        textField?.rightViewMode = .always
        textField?.font = UIFont(name: "Lato-Regular", size: 17)
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(barAction(sender:)))
    }
}

extension AddCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        currencyArray[section].first?.first?.uppercased()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencyArray[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "addCurrencyCell", for: indexPath)
        
        var content = cell.defaultContentConfiguration()
        content.text = currencyArray[indexPath.section][indexPath.row]
        cell.contentConfiguration = content
        
        return cell
    }
}

extension AddCurrencyViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
    }
    
    
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destination.
 // Pass the selected object to the new view controller.
 }
 */
