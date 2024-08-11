//
//  SceneDelegate.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 12/01/2024.
//

import UIKit
import BackgroundTasks

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let router = AppCoordinator().strongRouter    
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        if let window = window {
            router.setRoot(for: window)
        }
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate?.backgroundTasksManager.appLastOpenedDate = Date()
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        appDelegate?.saveContext()
        appDelegate?.backgroundTasksManager.scheduleBackgroundCurrenciesDataFetchIfNeeded()
    }
}
