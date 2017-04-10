//
//  AppDelegate.swift
//  domei
//
//  Created by Cliff Tanaka on 2017/03/28.
//  Copyright © 2017 kurifu. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseAuthUI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        let entity : TimerLogEntity = getTimerLogEntity()
        entity.setValue(MyTimerLog.log.key, forKey: "key")
        entity.setValue(MyTimerLog.log.interval, forKey: "interval")
        entity.setValue(MyTimerLog.log.startTime, forKey: "startTime")
        entity.setValue(MyTimerLog.log.pausedTime, forKey: "pausedTime")
        entity.setValue(MyTimerLog.log.timeStamp, forKey: "timeStamp")
        entity.setValue(MyTimerLog.log.pausedInterval, forKey: "pausedInterval")
        entity.setValue(MyTimerLog.log.isPaused, forKey: "isPaused")
        print(MyTimerLog.log.isPaused)
        
        self.saveContext()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        let entity : TimerLogEntity = getTimerLogEntity()
        MyTimerLog.log.key = entity.key!
        MyTimerLog.log.interval = entity.interval
        MyTimerLog.log.startTime = entity.startTime
        MyTimerLog.log.pausedTime = entity.pausedTime
        MyTimerLog.log.timeStamp = entity.timeStamp!
        MyTimerLog.log.pausedInterval = entity.pausedInterval
        MyTimerLog.log.isPaused = entity.isPaused
        print(MyTimerLog.log.isPaused)
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "domei")
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
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    @available(iOS 8.0, *)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.handleOpenUrl(url, sourceApplication: sourceApplication)
    }
    
    
    func handleOpenUrl(_ url: URL, sourceApplication: String?) -> Bool {
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
    
    func getTimerLogEntity() -> TimerLogEntity {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do {
            let entities = try context.fetch(TimerLogEntity.fetchRequest()) as! [TimerLogEntity]
            if entities.count != 0 {
                return entities[0]
            }
        } catch {
            
        }
        let entity = TimerLogEntity(context: context)
        entity.setValue("", forKey: "key")
        entity.setValue(0.0, forKey: "interval")
        entity.setValue(0.0, forKey: "startTime")
        entity.setValue(0.0, forKey: "pausedTime")
        entity.setValue("", forKey: "timeStamp")
        entity.setValue(0.0, forKey: "pausedInterval")
        entity.setValue(false, forKey: "isPaused")
        
        return entity
    }
}

