//
//  AppDelegate.swift
//  Zed
//
//  Created by Mark Angeles on 03/05/2016.
//  Copyright © 2016 Mark Angeles. All rights reserved.
//

import UIKit
import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import GoogleMaps
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
//        
//
//        return true
//    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
        
//        GMSServices.provideAPIKey("AIzaSyCVRfcouQyXB28ZfvbLZmoKjN5jOJJnJ1I")
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        self.saveContext()
    }
    
    
    // MARK: Delegate with Facebook api
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        //639066285538
        //6788 8800 0000 1347
        
        application.registerForRemoteNotifications()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        defaults.setObject("true", forKey: "identify_card")
        
        GMSServices.provideAPIKey("AIzaSyD6JXMgaHDYTeiDB0eGplaWIGtLlZs4nKE")
        syncBranchesData()
        
        self.identifyRootViewController()
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        //        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    //MARK: - Core Data
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("FunCard", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("Zed.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    //MARK: - Methods
    func identifyRootViewController() {
        let managedContext = self.managedObjectContext
        let fetchRequest = NSFetchRequest(entityName: "User")
        
        do {
            let results = try managedContext.executeFetchRequest(fetchRequest) as! [User]
            
            if results.count > 0 {
                let predicate = NSPredicate(format: "self.isLoggedIn == 1")
                let arrayFiltered = (results as NSArray).filteredArrayUsingPredicate(predicate)
                
                if arrayFiltered.count > 0 {
                    /*
                    //change root view controller
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let controller = storyboard.instantiateInitialViewController()
                    */
                    let storyboard = UIStoryboard(name: "Navigation", bundle: nil)
                    let vc = storyboard.instantiateViewControllerWithIdentifier("navigationView") as! FunNavigationController
                    self.window?.rootViewController = vc
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func syncBranchesData() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            let url:NSURL = NSURL(string: "http://180.87.143.52/funapp/GetBranches.aspx")!
            let session = NSURLSession.sharedSession()
            
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = "GET"
            request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringCacheData
            
            let task = session.dataTaskWithRequest(request) {
                (
                let data, let response, let error) in
                
                guard let _:NSData = data, let _:NSURLResponse = response  where error == nil else {
                    print("error")
                    return
                }
                
                do {
                    let objJSON = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    let results = objJSON["Result"]
                    if results == nil {
                        print("format/server error")
                        return
                    }
                    
                    if results!!.isKindOfClass(NSArray.classForCoder()) {
                        (results  as! NSArray).enumerateObjectsUsingBlock { (obj, index, stop) -> Void in
                            if obj.isKindOfClass(NSDictionary.classForCoder()) {
                                //save to core data
                                let managedContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType) //on bg thread
                                managedContext.persistentStoreCoordinator = self.persistentStoreCoordinator
                                
                                let entity =  NSEntityDescription.entityForName("Branch", inManagedObjectContext:managedContext)
                                let branch = NSManagedObject(entity: entity!, insertIntoManagedObjectContext: managedContext) as! Branch
                                
                                let dictObj = obj as! NSDictionary
                                branch.convertDictionaryToBranchManagedObject(dictObj)
                                
                                do {
                                    try managedContext.save()
                                } catch let error as NSError  {
                                    print("Could not save \(error), \(error.userInfo)")
                                }
                                
                            } else {
                                print("format/server error")
                            }
                        }
                    } else {
                        print("format/server error")
                    }
                    
                } catch let error as NSError {
                    print("json error: \(error.localizedDescription)")
                }
                
            }
            
            task.resume()
        })
    }
}

