//
//  AddCurrencyViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 22/04/2023.
//

import UIKit

class AddCurrencyViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        setUpSearchTextField()
    }
    
    private func setUpSearchTextField() {
        searchTextField.font = UIFont(name: "Lato-Regular", size: 17)
        searchTextField.placeholder = "Search Currency"
        
        // add magnifying glass image
        let magnifyingGlassImageView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchTextField.leftView = magnifyingGlassImageView
        searchTextField.leftViewMode = .always
        
        magnifyingGlassImageView.contentMode = .center
        magnifyingGlassImageView.tintColor = UIColor(red: 142/255, green: 142/255, blue: 142/255, alpha: 1)
        NSLayoutConstraint.activate([
            magnifyingGlassImageView.widthAnchor.constraint(equalToConstant: 30)
        ])
                
        // add dictation button
        let dictButton = UIButton()
        dictButton.tintColor = magnifyingGlassImageView.tintColor
        dictButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
        searchTextField.rightView = dictButton
        searchTextField.rightViewMode = .always
        
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
        
        searchTextField.layer.borderColor = CGColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1)
        searchTextField.layer.cornerRadius = 10
        
        searchTextField.borderStyle = .none
        searchTextField.keyboardType = .decimalPad
    }
}

extension AddCurrencyViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "addCurrencyCell", for: indexPath) as? AddCurrencyCell else {
            fatalError("Casting to \(AddCurrencyCell.self) failed")
        }
        
        return cell
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
