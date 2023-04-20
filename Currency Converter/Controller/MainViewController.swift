//
//  ViewController.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

class MainViewController: UIViewController {
    @IBOutlet weak var mainView: MainView!
    
    let elipseView = EllipseView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        elipseView.layoutViewIn(view)
        setUpMainView()
    }
    
    func setUpMainView() {
        mainView.setUpButtons()
    }
}

