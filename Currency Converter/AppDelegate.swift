//
//  AppDelegate.swift
//  Currency Converter
//
//  Created by Vladyslav Petrenko on 19/04/2023.
//

import UIKit
import CoreData
import BackgroundTasks

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    let mainViewController = MainViewController()
    
    var backgroundProcessingTask: BGProcessingTask?
    var appLastOpenedDate: Date?
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.vladylslavpetrenko.fetchCurrenciesData", using: nil) { task in
            self.handleAppRefreshTask(task: task as! BGProcessingTask)
        }
        return true
    }
    
    func handleAppRefreshTask(task: BGProcessingTask) {
        backgroundProcessingTask = task
        let backgroundURLSession = URLSession(configuration: .background(withIdentifier: "com.vladylslavpetrenko.backgroundDataFetch"),
                                              delegate: self,
                                              delegateQueue: .main)
        task.expirationHandler = {
            task.setTaskCompleted(success: false)
            backgroundURLSession.invalidateAndCancel()
        }
        
        mainViewController.currencyDataNetworkManager.fetchCurrencyData(urlSession: backgroundURLSession)
        
        guard let appLastOpenedDate = appLastOpenedDate else { return }
        
        // if user didn't open the app during last 24h since last open, then rates update once a day
        if appLastOpenedDate > Date(timeIntervalSinceNow: -(60 * 60 * 24)) {
            scheduleBackgroundCurrenciesDataFetch()
        } else {
            // id he did, then rates update once an hour
            scheduleBackgroundCurrenciesDataFetch(delayForBeginDate: 60 * 60 * 24)
        }
    }
    
    func scheduleBackgroundCurrenciesDataFetch(delayForBeginDate: TimeInterval = 0) {
        let currencyDataFetchTask = BGProcessingTaskRequest(identifier: "com.vladylslavpetrenko.fetchCurrenciesData")
        let calendarCurrentComponents = Calendar.current.dateComponents([.minute], from: Date())
        currencyDataFetchTask.requiresNetworkConnectivity = true
        // earliest update time in background is every hour e.g. at 7:00, 8:00 etc.
        currencyDataFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: delayForBeginDate + 60 * 60 - Double(calendarCurrentComponents.minute!) * 60)
        do {
          try BGTaskScheduler.shared.submit(currencyDataFetchTask)
        } catch let error as NSError {
          print("Unable to submit task: \(error.localizedDescription)")
        }
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}


// MARK: URLSessionDelegate
extension AppDelegate: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.finishTasksAndInvalidate()
    }
}

// MARK: URLSessionDataDelegate
extension AppDelegate: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let currencyParsedData = try? mainViewController.currencyDataNetworkManager.parseJSON(withData: data) else { return }

        try? mainViewController.currencyDataNetworkManager.updateCurrencySavedDataObjects(with: currencyParsedData)

        NotificationCenter.default.post(name: .curreniesDataFetched, object: self)
        guard let backgroundProcessingTask = backgroundProcessingTask else { return }
        backgroundProcessingTask.setTaskCompleted(success: true)
    }
}
