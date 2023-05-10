//
//  MainViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

final class MainViewController: UIViewController {
    @IBOutlet weak var mainWindowView: MainWindowView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var lastTimeUpdatedLabel: UILabel!
    
    let elipseView = EllipseView()
    let endEditingTapRecognizer = UITapGestureRecognizer()
    let editTableViewPressRecognizer = UILongPressGestureRecognizer()
    let currencyDataNetworkManager = CurrenciesDataNetworkManager()
    let coreDataManager = CoreDataManager()
    
    var favouriteCurrencies: [FavouriteCurrency] = []
    var lastActiveTextField: UITextField?
    var cells: [MainTableViewCell] {
        var cells: [MainTableViewCell] = []
        for i in 0..<favouriteCurrencies.count {
            guard let cell = mainWindowView.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? MainTableViewCell else { continue }
            cells.append(cell)
        }
        return cells
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elipseView.layoutViewIn(view)
        setUpGestureRecognizers()
        mainWindowView.setUpView()
        mainWindowView.tableView.dataSource = self
        mainWindowView.tableView.delegate = self
        addNotificationCenterObservers()
        getFavouriteCurrencies()
        addButtonsTagrets()
        fetchDataIfNeeded()
    }
    
    @objc private func scrollViewTapDetected() {
        view.endEditing(true)
    }
    
    @IBAction func shareButtonTapped(sender: UIButton) {
        var stringToShare = ""
        for cell in cells {
            guard let cellTextFieldText = cell.textField.text,
                  let cellLabelText = cell.currencyLabel.text,
                  !cellTextFieldText.isEmpty
            else { continue }
            stringToShare.append(("\(cellLabelText) \(cellTextFieldText)\n"))
        }
        if stringToShare.isEmpty {
            presentOkActionAlertController(title: "Nothing to share",
                                           message: "Please, type convert amount first")
            return
        }
        let activityViewController = UIActivityViewController(activityItems: [stringToShare], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func unwindSegueToTextFieldsVC(segue: UIStoryboardSegue) {
        // User cannot add more than 4 favourite currencies, if he tries then the currency in the bottom is replaced with new currency
        if favouriteCurrencies.count > 4 {
            favouriteCurrencies.remove(at: favouriteCurrencies.count - 2)
            guard let objects = try? coreDataManager.context.fetch(coreDataManager.favouriteCurrencyFetchRequest) else { return }
            coreDataManager.context.delete(objects[objects.count - 2])
            try? coreDataManager.context.save()
            let newCellIndexPath = [IndexPath(row: favouriteCurrencies.count - 1, section: 0)]
            mainWindowView.tableView.reloadRows(at: newCellIndexPath, with: .fade)
        } else {
            let newCellIndexPath = [IndexPath(row: favouriteCurrencies.count - 1, section: 0)]
            mainWindowView.tableView.insertRows(at: newCellIndexPath, with: .fade)
            mainWindowView.tableView.reloadRows(at: newCellIndexPath, with: .fade)
        }
        // Currency from last active textField will also be converted to new added favourite currency just after adding
        guard let lastActiveTextField = lastActiveTextField else { return }
        convertActiveTextFieldCurrencyToOtherCurrencies(lastActiveTextField)
    }
    
    func tryUpdateLastTimeUpdatedLabel() {
        guard let firstCurrency = try? coreDataManager.context.fetch(coreDataManager.currencySavedDataFetchRequest).first?.timeIntervalSinceLastUpdate else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy h:mm a"
        lastTimeUpdatedLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: firstCurrency))
    }
    
    func checkMaskForTextField(textField: UITextField) {
        enum AllowedSigns: String {
            case comma = ","
            case dot = "."
        }
        let allowedSigns = AllowedSigns.comma.rawValue + AllowedSigns.dot.rawValue
        guard let textFieldText = textField.text,
              let senderTextFirstCharacter = textFieldText.first,
              let indexOfCommaOrDot = textFieldText.firstIndex(where: { (character: Character) -> Bool in
                  allowedSigns.contains(character)
              })
        else { return }
        
        var newTextWithoutSigns = textField.text?.components(separatedBy: CharacterSet(charactersIn: allowedSigns)).joined()
        newTextWithoutSigns?.insert(".", at: indexOfCommaOrDot)
        textField.text = newTextWithoutSigns
        
        if allowedSigns.contains(senderTextFirstCharacter) {
            textField.text? = "0\(textFieldText)"
        }
        
        guard let separatedSenderText = textField.text?.components(separatedBy: "."),
              separatedSenderText[separatedSenderText.count - 1].count > 2
        else { return }
        textField.text?.removeLast(separatedSenderText[1].count - 2)
    }
    
    func convertActiveTextFieldCurrencyToOtherCurrencies(_ textField: UITextField) {
        let baseCurrencySumToConvert: Double
        guard let activeCell = textField.superview as? MainTableViewCell,
              let currencyDataObjects = try? coreDataManager.context.fetch(coreDataManager.currencySavedDataFetchRequest),
              let textFieldText = textField.text,
              let sumToConvert = Double(textFieldText)
        else {
            for cell in cells {
                cell.textField.text = ""
            }
            return
        }
        
        if activeCell.currencyLabel.text == "USD" {
            baseCurrencySumToConvert = sumToConvert
        } else {
            guard let activeCellCurrencyDataObject = currencyDataObjects.first(where: { object in
                object.quoteCurrency == activeCell.currencyLabel.text
            }) else { return }
            let baseCurrencyPriceCoefficient = mainWindowView.selectedButton == mainWindowView.bidButton ? activeCellCurrencyDataObject.bidPrice : activeCellCurrencyDataObject.askPrice
            baseCurrencySumToConvert = sumToConvert / baseCurrencyPriceCoefficient
            
            let usdCell = cells.first { cell in
                cell.currencyLabel.text == "USD"
            }
            usdCell?.textField.text = String(format: "%.2f", baseCurrencySumToConvert)
        }
        
        for cell in cells {
            guard cell != activeCell,
                  let currencyDataObject = currencyDataObjects.first (where: { object in
                      object.quoteCurrency == cell.currencyLabel.text
                  })
            else { continue }
            let currencyPriceCoefficient = mainWindowView.selectedButton == mainWindowView.bidButton ? currencyDataObject.bidPrice : currencyDataObject.askPrice
            cell.textField.text = String(format: "%.2f", (baseCurrencySumToConvert * currencyPriceCoefficient))
        }
    }
    
    func fetchDataIfNeeded() {
        currencyDataNetworkManager.fetchDataIfNeeded { errorTitle, errorMessage in
            if errorTitle != nil || errorMessage != nil {
                self.presentOkActionAlertController(title: errorTitle,
                                                    message: errorMessage)
            }
            self.tryUpdateLastTimeUpdatedLabel()
        }
    }
    
    func getFavouriteCurrencies() {
        do {
            favouriteCurrencies = try coreDataManager.getFavouriteCurrencies()
        } catch {
            presentOkActionAlertController(title: "Error occured when trying to read favourite currencies",
                                           message: error.localizedDescription)
        }
    }
    
    @objc func textFieldEditingChanged(sender: UITextField) {
        checkMaskForTextField(textField: sender)
        convertActiveTextFieldCurrencyToOtherCurrencies(sender)
    }
    
    @objc private func longPressDetected() {
        if editTableViewPressRecognizer.state == .began {
            let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred()
            prepareCellsForEditingToggle()
        }
    }
    
    @objc func askButtonTapped(sender: UIButton) {
        mainWindowView.buttonsUIUpdateAction(sender: sender)
        guard let lastActiveTextField = lastActiveTextField else { return }
        convertActiveTextFieldCurrencyToOtherCurrencies(lastActiveTextField)
    }
    
    @objc func bidButtonTapped(sender: UIButton) {
        mainWindowView.buttonsUIUpdateAction(sender: sender)
        guard let lastActiveTextField = lastActiveTextField else { return }
        convertActiveTextFieldCurrencyToOtherCurrencies(lastActiveTextField)
    }
    
    private func prepareCellsForEditingToggle() {
        if mainWindowView.tableView.isEditing {
            mainWindowView.tableView.isEditing.toggle()
            for cell in cells {
                cell.stackViewLeadingConstraint.constant = 32
                cell.textFieldTrailingConstraint.constant = -32
                UIView.animate(withDuration: 0.2) {
                    cell.layoutIfNeeded()
                }
            }
        } else {
            view.endEditing(true)
            for cell in cells {
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
    
    private func setUpGestureRecognizers() {
        editTableViewPressRecognizer.addTarget(self, action: #selector(longPressDetected))
        mainWindowView.tableView.addGestureRecognizer(editTableViewPressRecognizer)
        editTableViewPressRecognizer.minimumPressDuration = 0.75
        scrollView.addGestureRecognizer(endEditingTapRecognizer)
        endEditingTapRecognizer.cancelsTouchesInView = false
        endEditingTapRecognizer.addTarget(self, action: #selector(scrollViewTapDetected))
    }
    
    private func addButtonsTagrets() {
        mainWindowView.bidButton.addTarget(self, action: #selector(bidButtonTapped(sender:)), for: .touchUpInside)
        mainWindowView.askButton.addTarget(self, action: #selector(askButtonTapped(sender:)), for: .touchUpInside)
    }
    
    private func presentOkActionAlertController(title: String?, message: String?) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let destinationNavController = segue.destination as? UINavigationController
        let destinationVC = destinationNavController?.topViewController as? AddCurrencyTableViewController
        
        // favourite currencies will not exist in AddCurrencyTableVC
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

// MARK: UITableViewDataSource
extension MainViewController: UITableViewDataSource {
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
        
        // when rows were moved, then new order will be saved
        var currencyCodes: [String] = []
        for i in favouriteCurrencies {
            guard let currencyCode = i.currencyCode else { continue }
            currencyCodes.append(currencyCode)
        }
        
        coreDataManager.deleteObjects(from: coreDataManager.favouriteCurrencyFetchRequest)
        
        favouriteCurrencies.removeAll()
        for currencyCode in currencyCodes {
            do {
                try coreDataManager.saveFavouriteCurrency(currencyCode: currencyCode)
            } catch {
                presentOkActionAlertController(title: "Unable to add \(currencyCode) to favourites",
                                               message: error.localizedDescription)
            }
            do {
                favouriteCurrencies = try coreDataManager.getFavouriteCurrencies()
            } catch {
                presentOkActionAlertController(title: "Error occured when trying to read favourite currencies",
                                               message: error.localizedDescription)
            }
        }
    }
}

// MARK: UITableViewDelegate
extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { _, _, _ in
            let currencyObject = self.favouriteCurrencies[indexPath.row]
            self.coreDataManager.context.delete(currencyObject)
            try? self.coreDataManager.context.save()
            
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
        textField.textColor = UIColor.activeText
        lastActiveTextField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0
        textField.textColor = UIColor.inactiveText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        enum AllowedSigns: String {
            case comma = ","
            case dot = "."
        }
        let allowedSignsCharacterSet = CharacterSet(charactersIn: AllowedSigns.comma.rawValue + AllowedSigns.dot.rawValue)
        let setOfAllowedCharacters = CharacterSet.decimalDigits.union(allowedSignsCharacterSet)
        if setOfAllowedCharacters.isSuperset(of: CharacterSet(charactersIn: string)) {
            return true
        }
        return false
    }
}

// MARK: NotificationCenter
extension MainViewController {
    private func addNotificationCenterObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotificationTriggered(notification:)),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotificationTriggered(notification:)),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(forName: .curreniesDataFetched,
                                               object: nil,
                                               queue: nil) { _ in
            self.tryUpdateLastTimeUpdatedLabel()
        }
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
}
