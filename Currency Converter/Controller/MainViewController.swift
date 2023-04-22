//
//  ViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var mainWindowView: MainWindowView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let elipseView = EllipseView()
    var currencyArray = [
        "USD",
        "EUR",
        "PLN"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elipseView.layoutViewIn(view)
        mainWindowView.setUpView()
        mainWindowView.tableView.dataSource = self
        mainWindowView.tableView.delegate = self
        scrollView.delegate = self
        addNotificationCenterObservers()
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
    
    @objc func keyboardNotificationTriggered(notification: Notification) {
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

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currencyArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MainTableViewCell else {
            fatalError("Casting to \(MainTableViewCell.self) failed")
        }
        cell.currencyLabel.text = currencyArray[indexPath.row]
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(textFieldEditingChanged(sender:)), for: .editingChanged)
        return cell
    }
}

extension MainViewController: UITextFieldDelegate {
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

