//
//  AppDelegate.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 12/01/2024.
//

import UIKit
import CoreData
import BackgroundTasks
import OSLog

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    let networkCurrenciesDataManager = NetworkRatesDataManager()
    let coreDataManager = CoreDataManager()
    
    var backgroundProcessingTask: BGProcessingTask?
    var appLastOpenedDate: Date?
    
    let logger = Logger()
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.vladylslavpetrenko.fetchCurrenciesData", using: nil) { task in
            guard let task = task as? BGProcessingTask else { return }
            self.handleAppRefreshTask(task: task)
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
        
        networkCurrenciesDataManager.fetchCurrencyRatesData(urlSession: backgroundURLSession)
        
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
        let currentMinutes = Calendar.current.dateComponents([.minute], from: Date()).minute ?? 0
        currencyDataFetchTask.requiresNetworkConnectivity = true
        // earliest update time in background is every hour e.g. at 7:00, 8:00 etc.
        currencyDataFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: delayForBeginDate + 60 * 60 - Double(currentMinutes) * 60)
        do {
          try BGTaskScheduler.shared.submit(currencyDataFetchTask)
        } catch let error as NSError {
            logger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }

    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CurrencyConverter")
        container.loadPersistentStores(completionHandler: { [weak self] (storeDescription, error) in
            if let error = error as NSError? {
                self?.logger.error("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                logger.error("Unresolved error \(nserror), \(nserror.userInfo)")
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
        guard let currencyParsedData = try? networkCurrenciesDataManager.parseJSON(withRatesData: data) else { return }
        coreDataManager.updateCurrencyRatesSavedDataObjects(with: currencyParsedData)

        NotificationCenter.default.post(name: .curreniesDataFetched, object: self)
        if let backgroundProcessingTask = backgroundProcessingTask {
            backgroundProcessingTask.setTaskCompleted(success: true)
        }
    }
}
