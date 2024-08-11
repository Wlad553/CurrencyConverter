//
//  BackgroundTaskManager.swift
//  CurrencyConverter
//
//  Created by Vladyslav Petrenko on 10/08/2024.
//
// e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.vladylslavpetrenko.fetchCurrenciesData"] - for test purposes

import CoreData
import BackgroundTasks
import OSLog

final class BackgroundTasksManager: NSObject {
    let networkCurrenciesDataManager = NetworkRatesDataManager()
    let coreDataManager = CoreDataManager()
    
    let taskId = "com.vladylslavpetrenko.fetchCurrenciesData"
    let backgroundSessionIdentifier = "com.vladylslavpetrenko.backgroundDataFetch"
    
    var backgroundProcessingTask: BGProcessingTask?
    var appLastOpenedDate: Date?
    
    let logger = Logger()
    
    func registerTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskId, using: nil) { task in
            guard let task = task as? BGProcessingTask else { return }
            self.handleAppRefreshTask(task: task)
        }
    }
    
    func handleAppRefreshTask(task: BGProcessingTask) {
        backgroundProcessingTask = task
        let backgroundURLSession = URLSession(configuration: .background(withIdentifier: backgroundSessionIdentifier),
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
        let currencyDataFetchTask = BGProcessingTaskRequest(identifier: taskId)
        let currentMinutes = Calendar.current.dateComponents([.minute], from: Date()).minute ?? 0
        currencyDataFetchTask.requiresNetworkConnectivity = true
        currencyDataFetchTask.requiresExternalPower = false
        // earliest update time in background is every hour e.g. at 7:00, 8:00 etc.
        currencyDataFetchTask.earliestBeginDate = Date(timeIntervalSinceNow: delayForBeginDate + 60 * 60 - Double(currentMinutes) * 60)
        do {
          try BGTaskScheduler.shared.submit(currencyDataFetchTask)
        } catch let error as NSError {
            logger.error("Unable to submit task: \(error.localizedDescription)")
        }
    }
    
    func scheduleBackgroundCurrenciesDataFetchIfNeeded() {
        Task {
            if await BGTaskScheduler.shared.pendingTaskRequests().first(where: { $0.identifier == taskId }) == nil {
                scheduleBackgroundCurrenciesDataFetch()
            }
        }
    }
}

// MARK: URLSessionDelegate
extension BackgroundTasksManager: URLSessionDelegate {
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        session.finishTasksAndInvalidate()
    }
}

// MARK: URLSessionDataDelegate
extension BackgroundTasksManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard let currencyParsedData = try? networkCurrenciesDataManager.parseJSON(withRatesData: data) else { return }
        coreDataManager.updateCurrencyRatesSavedDataObjects(with: currencyParsedData)

        NotificationCenter.default.post(name: .curreniesDataFetched, object: self)
        if let backgroundProcessingTask = backgroundProcessingTask {
            backgroundProcessingTask.setTaskCompleted(success: true)
        }
    }
}
