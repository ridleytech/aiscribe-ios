//
//  AppDelegate.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/18/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import SystemConfiguration
import AWSS3
import AWSCognito

import FBSDKCoreKit
//import GooglePlaces

import FacebookCore
import FacebookLogin
import Stripe
import UserNotifications
import HockeySDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var crGray : UIColor = UIColor.init(red: 91.0/255.0, green: 92.0/255.0, blue: 89.0/255.0, alpha: 1.0)
    var crOrange : UIColor = UIColor.init(red: 229.0/255.0, green: 89.0/255.0, blue: 52.0/255.0, alpha: 1.0)
    var crOrange2 : UIColor = UIColor.init(red: 250.0/255.0, green: 121.0/255.0, blue: 33.0/255.0, alpha: 1.0)
    var crOrange3 : UIColor = UIColor.init(red: 219.0/255.0, green: 107.0/255.0, blue: 29.0/255.0, alpha: 1.0)
    var crWarmGray : UIColor = UIColor.init(red: 155.0/255.0, green: 155.0/255.0, blue: 155.0/255.0, alpha: 1.0)
    var crLightBlue : UIColor = UIColor.init(red: 91/255.0, green: 192/255.0, blue: 235/255.0, alpha: 1.0)
    var crGreen : UIColor = UIColor.init(red: 134/255.0, green: 183/255.0, blue: 24/255.0, alpha: 1.0)
    var crGreen2 : UIColor = UIColor.init(red: 155/255.0, green: 197/255.0, blue: 61/255.0, alpha: 1.0)
    var crGreen3 : UIColor = UIColor.init(red: 156/255.0, green: 195/255.0, blue: 72/255.0, alpha: 1.0)
    
    var gray51 : UIColor = UIColor.init(red: 51/255.0, green: 51/255.0, blue: 51/255.0, alpha: 1.0)
    var gray180 : UIColor = UIColor.init(red: 180/255.0, green: 180/255.0, blue: 180/255.0, alpha: 1.0)
    var tomato : UIColor = UIColor.init(red: 229/255.0, green: 89/255.0, blue: 52/255.0, alpha: 1.0)

    var whitefive : UIColor = UIColor.init(red: 247/255.0, green: 247/255.0, blue: 247/255.0, alpha: 1.0)
    var gray74 : UIColor = UIColor.init(red: 74.0/255.0, green: 74.0/255.0, blue: 74.0/255.0, alpha: 1.0)
    var blue56 : UIColor = UIColor.init(red: 56/255.0, green: 216/255.0, blue: 212/255.0, alpha: 1.0)

    
    var serverDestination : String?
    var userid : String!
    var genuserid : String!
    var loggedIn : Bool?
    var profileImg : String?
    var fbID : String?
    var firstname: String!
    var lastname: String!
    var city: String!
    var state: String!
    var country: String!
    var zip: String!
    var email: String!
    var username: String!
    var mobile: String!
    var password: String!
    var referralCode: String!
    var userImagename: String!
    var birthday: String!
    var credits: String!
    var gender: Int!
    
    var userImage : UIImage?
    
    var debug : Bool?
    
    var lat: String!
    var lng: String!
    
    var fullVersion : Bool?
    var initLoaded : Bool = false
    var cloudVersion : Int = 0
    var isAuthenticated : Bool?
    var usertype : String?
    var deviceid : String?
    var devicetoken : String?
    var viewMessageIdentifier = "VIEW_MESSAGE"
    var messageCategoryIdentifier = "MESSAGE_CATEGORY"
    var pushMessageUserID : String?
    
    var isFBLogin : Bool?
    var isTwitterLogin : Bool?
    var notificationsSetting : Int = 0
    let prefs = UserDefaults.standard
    
    var isAddingFamily : Bool?
    var signingUp : Bool?
    
    var devStage : String?
    
    var downloadImages : Bool?
    var dob : String?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        fullVersion = true
        downloadImages = true
        
        //$(SWIFT_MODULE_NAME)-Swift.h
        
        //TestFairy.begin("ec963cd05b830146b2cf9039a57ee8bf80b07863")
        
        debug = true
        
        #if (arch(i386) || arch(x86_64)) && os(iOS)
            
            //print("simulator")
            
        #else
        
            //print("not simulator")
            
            debug = false;
            
        #endif
        
        //debug = false;
        //userid = "1"
        
        //debug = false
        
        devStage = "prod"
        
        if debug == true
        {
            serverDestination = "http://localhost:8888/aiscribe/"
        }
        else
        {
            serverDestination = "http://54.69.237.232/"
        }
        
        if prefs.integer(forKey: "notifications") != nil
        {
            notificationsSetting = prefs.integer(forKey: "notifications")
        }
        
        registerForPushNotifications()
        
        //GMSPlacesClient.provideAPIKey("AIzaSyDvvRuNaxaUdIw1l2f-MjyWQO_2KcMIM-0")
        
        UNUserNotificationCenter.current().delegate = self
        
        initAWS()
        //initPayments()
        initHockey()
        
        AppEventsLogger.activate(application)
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func initPayments () {
        
        STPPaymentConfiguration.shared().publishableKey = "pk_test_6pRNASCoBOKtIshFeQd4XMUh"
        STPPaymentConfiguration.shared().appleMerchantIdentifier = "your apple merchant identifier"
    }
    
    func initHockey () {
        
        BITHockeyManager.shared().configure(withIdentifier: "a8ac9f9fa8ef463dac8cfd8740c6dad2")
        BITHockeyManager.shared().start()
        BITHockeyManager.shared().authenticator.authenticateInstallation()
    }

    func registerForPushNotifications() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            
            guard granted else { return }
            
            // 1
            let viewAction = UNNotificationAction(identifier: self.viewMessageIdentifier,
                                                  title: "View",
                                                  options: [.foreground])
            
            // 2
            let messageCategory = UNNotificationCategory(identifier: self.messageCategoryIdentifier,
                                                         actions: [viewAction],
                                                         intentIdentifiers: [],
                                                         options: [])
            // 3
            UNUserNotificationCenter.current().setNotificationCategories([messageCategory])
            
            self.getNotificationSettings()
        }
    }
    
    func getNotificationSettings() {
        
        UNUserNotificationCenter.current().getNotificationSettings { (settings) in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        devicetoken = tokenParts.joined()
        print("Device Token: \(devicetoken!)")
        
        if userid != nil
        {
            //NotificationCenter.default.post(name: Notification.Name("updateToken"), object: nil)
        }
    }
    
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url as URL!, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    func initAWS () {
        
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType:.USEast2,
                                                                identityPoolId:"us-east-2:81c9384e-b1e7-4a25-b9dc-5bbd9fb2971d")
        
        let configuration = AWSServiceConfiguration(region:.USEast2, credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func checkNull (param: AnyObject) -> AnyObject
    {
        if param.isMember(of: NSNull.self)
        {
            return "" as AnyObject
        }
        else
        {
            return param as AnyObject
        }
    }
    
    func randomString(length: Int) -> String {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let len = UInt32(letters.length)
        
        var randomString = ""
        
        for _ in 0 ..< length {
            let rand = arc4random_uniform(len)
            var nextChar = letters.character(at: Int(rand))
            randomString += NSString(characters: &nextChar, length: 1) as String
        }
        
        return randomString
    }
    
    func currentTime (date : Date) -> String {
        
        let inputFormatter = DateFormatter()
        
        //var dateNow = NSDate()
        
        inputFormatter.dateFormat = "hh:mm a"
        
        let theLoggedInTokenTimestampDateEpochSeconds = date.timeIntervalSince1970
        
        let timeInt = Int(theLoggedInTokenTimestampDateEpochSeconds)
        
        //NSLog(@"timeInt now: %d",timeInt);
        
        let dateNow = Date.init(timeIntervalSinceReferenceDate: TimeInterval(timeInt))
        
        //NSLog(@"date: %@",[inputFormatter stringFromDate:dateNow]);
        
        let s = inputFormatter.string(from: dateNow as Date)
        
        return s;
    }
    
    func convertSQLDateTime (origDate : String) -> String {
        
        let inputFormatter = DateFormatter()
        
        //var dateNow = NSDate()
        
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let d : Date = inputFormatter.date(from: origDate)!
        
        let df = DateFormatter()
        
        df.dateFormat = "MM/d/yy hh:mm a"
        
        let cv : String = df.string(from: d)
        
        return cv;
    }
    
    func convertSQLDateTimeProfile (origDate : String) -> String {
        
        let inputFormatter = DateFormatter()
        
        //var dateNow = NSDate()
        
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let d : Date = inputFormatter.date(from: origDate)!
        
        let df = DateFormatter()
        
        df.dateFormat = "MM/d/yy"
        
        let cv : String = df.string(from: d)
        
        return cv;
    }
    
    func formatMessageDate (date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy hh:mm a"
        let selectedDate = dateFormatter.string(from: Date())
        
        return selectedDate;
    }
    
    func formatMessageDate1 (date : Date, format: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        let selectedDate = dateFormatter.string(from: date)
        
        return selectedDate;
    }
    
    func convertDateToSQLTime (date : Date) -> String {
        
        let inputFormatter = DateFormatter()
        
        inputFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let selectedDate = inputFormatter.string(from: date)
        
        return selectedDate
    }
    
    func convertDateToSQLDate (date : Date) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let selectedDate = dateFormatter.string(from: date)
        
        return selectedDate
    }
    
    func validateDate(date:String)->Bool {
        
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM/yyyy"
        let someDate = date
        
        if dateFormatterGet.date(from: someDate) != nil {
            
            let calendar = Calendar.current
            let year = calendar.component(.year, from: dateFormatterGet.date(from: someDate)!)
            
            print("valid: \(year)")
            
            return true
            
        } else {
            
            print("invalid")
            
            return false
        }
    }
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress)
        {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress) }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        
        return (isReachable && !needsConnection)
    }
    
    func randomStringWithLength (len : Int) -> NSString {
        
        let letters : NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        
        let randomString : NSMutableString = NSMutableString(capacity: len)
        
        for i : Int in 0 ..< len
        {
            let length = UInt32 (letters.length)
            let rand = arc4random_uniform(length)
            randomString.appendFormat("%C", letters.character(at: Int(rand)))
        }
        
        return randomString
    }
    
    func isStringAnInt(string: String) -> Bool {
        
        return Int(string) != nil || Float(string) != nil
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "AIScribe")
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // 1
        let userInfo = response.notification.request.content.userInfo
        let aps = userInfo["aps"] as! [String: AnyObject]
        
        if aps["category"]! as! String == messageCategoryIdentifier
        {
            pushMessageUserID = aps["body"]! as? String
            
            print("pushMessageUserID: \(pushMessageUserID!)")
            
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "returnHome"), object: nil)
            NotificationCenter.default.post(name: Notification.Name("goToMessages"), object: nil)
        }
        
        completionHandler()
    }
}

