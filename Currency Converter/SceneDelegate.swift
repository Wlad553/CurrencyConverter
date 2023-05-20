//
//  SceneDelegate.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func sceneDidBecomeActive(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.appLastOpenedDate = Date()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.scheduleBackgroundCurrenciesDataFetch()
    }
}

