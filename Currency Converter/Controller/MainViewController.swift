//
//  ViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit
import CoreData

final class MainViewController: UIViewController {
    @IBOutlet weak var mainWindowView: MainWindowView!
    @IBOutlet weak var scrollView: UIScrollView!
    let elipseView = EllipseView()
    let endEditingTapRecognizer = UITapGestureRecognizer()
    let editTableViewPressRecognizer = UILongPressGestureRecognizer()
    
    var favouriteCurrencies: [FavouriteCurrency] = []
    
    private lazy var context: NSManagedObjectContext = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CurrenciesDataNetworkManager.shared.fetchDataIfNeeded()
        elipseView.layoutViewIn(view)
        setUpGestureRecognizers()
        mainWindowView.setUpView()
        mainWindowView.tableView.dataSource = self
        mainWindowView.tableView.delegate = self
        addNotificationCenterObservers()
        getFavouriteCurrenciesData()
    }
    
    @objc private func scrollViewTapDetected() {
        view.endEditing(true)
    }
    
    func saveFavouriteCurrency(currencyCode: String) {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavouriteCurrency", in: context),
              let currency = Currency(currencyCode: currencyCode)
        else { return }
        let currencyObject = FavouriteCurrency(entity: entity, insertInto: context)
        currencyObject.currencyCode = currency.currencyCode
        
        do {
            try context.save()
            favouriteCurrencies.append(currencyObject)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }
    
    @IBAction func unwindSegueToTextFieldsVC(segue: UIStoryboardSegue) {
        mainWindowView.tableView.reloadData()
    }
        
    @objc func textFieldEditingChanged(sender: UITextField) {
        guard let senderText = sender.text,
              let senderTextFirstCharacter = senderText.first,
              let indexOfCommaOrDot = senderText.firstIndex(where: { (character: Character) -> Bool in
                  ".,".contains(character)
              })
        else { return }
        
        var newTextWithoutSigns = sender.text?.components(separatedBy: CharacterSet(charactersIn: ",.")).joined()
        newTextWithoutSigns?.insert(".", at: indexOfCommaOrDot)
        sender.text = newTextWithoutSigns
        
        if ",.".contains(senderTextFirstCharacter) {
            sender.text? = "0\(senderText)"
        }
        
        guard let separatedSenderText = sender.text?.components(separatedBy: "."),
              separatedSenderText[separatedSenderText.count - 1].count > 2
        else { return }
            sender.text?.removeLast(separatedSenderText[1].count - 2)
    }
    
    @objc private func keyboardNotificationTriggered(notification: Notification) {
        guard let userInfo = notification.userInfo as? [String: Any],
              let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardFrame.height, right: 0)
            scrollView.scrollIndicatorInsets = scrollView.contentInset
        }
    }
    
    @objc private func longPressDetected() {
        if editTableViewPressRecognizer.state == .began {
            prepareCellsForEditingToggle()
        }
    }
    
    private func prepareCellsForEditingToggle() {
        if mainWindowView.tableView.isEditing {
            mainWindowView.tableView.isEditing.toggle()
            for i in 0..<favouriteCurrencies.count {
                guard let cell = mainWindowView.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MainTableViewCell else { return }
                cell.stackViewLeadingConstraint.constant = 32
                cell.textFieldTrailingConstraint.constant = -32
                UIView.animate(withDuration: 0.2) {
                    cell.layoutIfNeeded()
                }
            }
        } else {
            view.endEditing(true)
            for i in 0..<favouriteCurrencies.count {
                guard let cell = mainWindowView.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MainTableViewCell else { return }
                cell.stackViewLeadingConstraint.constant = 56
                cell.textFieldTrailingConstraint.constant = -56
                UIView.animate(withDuration: 0.2) {
                    cell.layoutIfNeeded()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.mainWindowView.tableView.isEditing.toggle()
            }
        }
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
    
    private func getFavouriteCurrenciesData() {
        let userDefaults = UserDefaults.standard
        if userDefaults.bool(forKey: "isAppAlreadyLauchedOnce") {
            let fetchRequest: NSFetchRequest<FavouriteCurrency> = FavouriteCurrency.fetchRequest()
            do {
                favouriteCurrencies = try context.fetch(fetchRequest)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            userDefaults.set(true, forKey: "isAppAlreadyLauchedOnce")
            ["USD", "EUR", "PLN"].forEach { currencyCode in
                saveFavouriteCurrency(currencyCode: currencyCode)
            }
        }
    }
    
    private func setUpGestureRecognizers() {
        editTableViewPressRecognizer.addTarget(self, action: #selector(longPressDetected))
        mainWindowView.tableView.addGestureRecognizer(editTableViewPressRecognizer)
        editTableViewPressRecognizer.minimumPressDuration = 0.75
        scrollView.addGestureRecognizer(endEditingTapRecognizer)
        endEditingTapRecognizer.cancelsTouchesInView = false
        endEditingTapRecognizer.addTarget(self, action: #selector(scrollViewTapDetected))
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let destinationNavController = segue.destination as? UINavigationController
        let destinationVC = destinationNavController?.topViewController as? AddCurrencyTableVC
        
        for currencyObject in favouriteCurrencies {
            guard let currencyCode = currencyObject.currencyCode,
                 let currencyToBeRemoved = Currency(currencyCode: currencyCode) else { continue }
            destinationVC?.currenciesSet.remove(currencyToBeRemoved)
        }
        
        if mainWindowView.tableView.isEditing {
            prepareCellsForEditingToggle()
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate {
    
    // MARK: UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favouriteCurrencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MainTableViewCell else {
            fatalError("Casting to \(MainTableViewCell.self) failed")
        }
        cell.currencyLabel.text = favouriteCurrencies[indexPath.row].currencyCode
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldEditingChanged(sender:)), for: .editingChanged)
        return cell
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let currencyObject = favouriteCurrencies.remove(at: sourceIndexPath.row)
        favouriteCurrencies.insert(currencyObject, at: destinationIndexPath.row)
        
        var currencyCodes: [String] = []
        for i in favouriteCurrencies {
            guard let currencyCode = i.currencyCode else { continue }
            currencyCodes.append(currencyCode)
        }
        
        for currencyObject in favouriteCurrencies {
            context.delete(currencyObject)
        }
        favouriteCurrencies.removeAll()
        for currencyCode in currencyCodes {
            saveFavouriteCurrency(currencyCode: currencyCode)
        }
    }
    
    // MARK: UITableViewDelegate
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            let currencyObject = self.favouriteCurrencies[indexPath.row]
            self.context.delete(currencyObject)
            
            do {
                try self.context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
            
            self.favouriteCurrencies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = UIColor.systemRed
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
}

// MARK: UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if mainWindowView.tableView.isEditing {
            return false
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1
        textField.textColor = UIColor(red: 1/255, green: 35/255, blue: 83/255, alpha: 1)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.textColor = UIColor(red: 69/255, green: 69/255, blue: 69/255, alpha: 1)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let setOfAllowedCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".,"))
        if setOfAllowedCharacters.isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        return false
    }
}
