//
//  Login.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/18/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit
import CoreLocation
import AVFoundation
import FBSDKLoginKit
import FBSDKCoreKit
import LocalAuthentication

class Login: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var usernameTxt: UITextField!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var passwordTxt: UITextField!
    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxt: UITextField!
    
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var showSignupBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var emailUnderscoreView: UIView!

    @IBOutlet weak var usernameLblHeight: NSLayoutConstraint!
    @IBOutlet weak var emailUnderscoreHeight: NSLayoutConstraint!
    @IBOutlet weak var emailLblHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordLblHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTxtHeight: NSLayoutConstraint!
    
    @IBOutlet weak var emailTxtTopPadding: NSLayoutConstraint!
    @IBOutlet weak var passwordLblTopPadding: NSLayoutConstraint!
    @IBOutlet weak var passwordTxtTopPadding: NSLayoutConstraint!
    @IBOutlet weak var emailLblTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var socialViewPaddingTop: NSLayoutConstraint!
    @IBOutlet weak var instructionsLblPaddingToop: NSLayoutConstraint!
    @IBOutlet weak var instructionsLbl: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var socialView: UIView!
    
    var basicInfoCompleted : String?
    var accountConfirmed : String?
    
    var status : String?
    
    let prefs = UserDefaults.standard
    
    var inputList = NSMutableArray()
    
    var locationManager: CLLocationManager = CLLocationManager()
    var startLocation: CLLocation!
    
    var isLoggingIn : Bool?
    
    var dict : [String : AnyObject]?
    var isNewUser : Bool = false
    var hasAccount : Bool?
    var usingFB : Bool?
    
    var signupInputs : [UITextField]?
    var loginpInputs : [UITextField]?
    
    @IBOutlet weak var instructionsLblHeight: NSLayoutConstraint!
    
    @IBOutlet weak var sv: UIScrollView!
    @IBOutlet weak var touchIDBtn: UIButton!
    var touchIDAlert: UIAlertController?
    
    @IBOutlet weak var viewPasswordBtn: UIButton!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        signupInputs = [usernameTxt, emailTxt, passwordTxt]
        loginpInputs = [usernameTxt, passwordTxt]
                
        usernameTxt.delegate = self
        emailTxt.delegate = self
        passwordTxt.delegate = self
        
        usernameLbl.isHidden = true
        emailLbl.isHidden = true
        passwordLbl.isHidden = true
        //instructionsLbl.isHidden = true
        
        touchIDBtn.isHidden = true
        
        usernameLblHeight.constant = 0
        emailLblHeight.constant = 0
        passwordLblHeight.constant = 0
        //socialViewPaddingTop.constant = 0
        
        instructionsLblPaddingToop.constant = 0
        //instructionsLblHeight.constant = 0
        
        instructionsLbl.text = ""
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.crWarmGray
        
        submitBtn.layer.cornerRadius = submitBtn.frame.width/2

        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
    
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
        btnItem]
    
        numberToolbar.sizeToFit()
    
        usernameTxt.inputAccessoryView = numberToolbar
        emailTxt.inputAccessoryView = numberToolbar
        passwordTxt.inputAccessoryView = numberToolbar
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(showResetInstructions),
                                               name: NSNotification.Name(rawValue: "showResetInstructions"),
                                               object: nil)
        initStuff()
        //debug()
        
        showLogin()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(Login.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Login.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let modelName = UIDevice.modelName
        
        if modelName.contains("iPhone 5")
        {
            sv.frame = CGRect.init(x: 0, y: sv.frame.origin.y, width: view.frame.width, height: sv.frame.height)
            sv.contentSize = CGSize.init(width: view.frame.width, height: 700)
            
            sv.layoutSubviews()
        }
    }
    
    func initStuff() {
        
        //http://blogs.innovationm.com/linkedin-integration-in-swift-3-0/
        
        print(self.appDelegate.formatMessageDate(date: Date()))
        
        //print(self.view.frame.height)
        
        //        if self.view.frame.height < 600
        //        {
        //            loginHeight.constant = 35
        //            membershipHeight.constant = 35
        //            fbTopMargin.constant = 0
        //            fbHeight.constant = 25
        //            loginTypeHeight.constant = 35
        //            passwordTopMargin.constant = 5
        //        }
        
        if FBSDKAccessToken.current() != nil {
            
            print("has logged into FB")
            
            self.logUserData()
        }
        
        if prefs.string(forKey: "fbid") != nil  {
            
            appDelegate.fbID = prefs.string(forKey: "fbid")
            
            //            appDelegate.firstname = prefs.string(forKey: "firstname")
            //            appDelegate.lastname = prefs.string(forKey: "lastname")
            //            appDelegate.email = prefs.string(forKey: "email")
            //            appDelegate.profileImg = prefs.string(forKey: "profileImg")
            //            appDelegate.referralCode = prefs.string(forKey: "code")
        }
        
        activityView.isHidden = true
        
        inputList = [emailTxt,passwordTxt]
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        startLocation = nil
        
        if prefs.string(forKey: "cloudVersion") != nil
        {
            appDelegate.cloudVersion = Int(prefs.string(forKey: "cloudVersion")!)!
        }
        
        if prefs.string(forKey: "upgraded") != nil || prefs.bool(forKey: "nonConsumablePurchaseMade")
        {
            appDelegate.fullVersion = true
        }
        
        let attributedString = NSMutableAttributedString(string: "LOGIN", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        loginBtn.setAttributedTitle(attributedString, for: .normal)
        
        let attributedString2 = NSMutableAttributedString(string: "SIGNUP", attributes: [
            .font: UIFont(name: "Avenir-Heavy", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        showSignupBtn.setAttributedTitle(attributedString2, for: .normal)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(logout1),
                                               name: NSNotification.Name(rawValue: "Logout"),
                                               object: nil)
        
        print("login full: \(appDelegate.fullVersion!)")
        
        //listFiles2()
        //makeVideoOverlay()
        
        //listFilesFromDocumentsFolder()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(udpateTokenNotification),
            name: NSNotification.Name(rawValue: "updateToken"),
            object: nil)
        
        let myContext = LAContext()
        var authError: NSError?
        
        //check for touchID funcitonality
        
       if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
        
        if let username = prefs.string(forKey: "username"), let _ = prefs.string(forKey: "password")
                {
                    
                    usernameTxt.text = username
                    //print("show touch ID buttun")
                    //touchIDBtn.isHidden = false
                    
                    promptTouchID()
                }
        }
        else
        {
            //check auto login
            
//            prefs.removeObject(forKey: "username")
//            prefs.removeObject(forKey: "password")
//
//            prefs.synchronize()
            
            if checkAutoLogin() == true
            {
                performSegue(withIdentifier: "AutoLogin", sender: nil)
            }
            else
            {
                print("no")
            }
        }
    }
    
    // MARK: Notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            
            if self.view.frame.origin.y == 0 {
                
                print("go up")
                
                //self.view.frame.origin.y -= keyboardSize.height
                self.view.frame.origin.y -= 200
            }
            else
            {
                print("other")
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        if self.view.frame.origin.y != 0 {
            
            print("reset")
            
            self.view.frame.origin.y = 0
        }
        else
        {
            print("other 2")
        }
    }
    
    func validateInputs () {
        
        if isLoggingIn == true
        {
            for input in loginpInputs!
            {
                if input.text == ""
                {
                    submitBtn.isEnabled = false
                    submitBtn.backgroundColor = appDelegate.crWarmGray
                    return
                }
            }
        }
        else
        {
            for input in signupInputs!
            {
                if input.text == ""
                {
                    submitBtn.isEnabled = false
                    submitBtn.backgroundColor = appDelegate.crWarmGray
                    return
                }
            }
        }

        submitBtn.isEnabled = true
        submitBtn.backgroundColor = appDelegate.crLightBlue
    }
    
    @objc func showResetInstructions (notification: NSNotification) {
        
        let attributedString = NSMutableAttributedString(string: "Instructions to reset your password have been sent to your email stellachandler@email.com. Please check your inbox to continue.", attributes: [
            .font: UIFont(name: "Avenir-Light", size: 14.0)!,
            .foregroundColor: appDelegate.crGray
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Medium", size: 14.0)!, range: NSRange(location: 65, length: 25))
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Book", size: 14.0)!, range: NSRange(location: 91, length: 36))
        
        instructionsLbl.attributedText = attributedString
        
        socialViewPaddingTop.constant = 20
        instructionsLbl.isHidden = false
        
        instructionsLblPaddingToop.constant = 20
        instructionsLblHeight.constant = 57
    }
    
    func checkFBCreds() {
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        let urlString = "\(appDelegate.serverDestination!)getFBCredentials.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "fbid=\(self.appDelegate.fbID!)&devStatus=\(appDelegate.devStage!)"
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        print("login decryptParam: \(paramString)")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            //print("Entered the completionHandler: \(response)")
            
            //var err: NSError?
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print("loginData: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                print("dataDict: \(dataDict)")
                
                let uploadData : NSDictionary = dataDict.object(forKey: "loginData") as! NSDictionary
                
                self.status = uploadData.object(forKey: "status") as? String
                
                if self.status != nil && self.status == "Logged in" {
                    
                    //                        self.appDelegate.firstname = uploadData.object(forKey: "firstname") as? String
                    //                        self.appDelegate.lastname = uploadData.object(forKey: "lastname") as? String
                    self.appDelegate.email = uploadData.object(forKey: "email") as? String
                    //                        self.appDelegate.city = uploadData.object(forKey: "city") as? String
                    //                        self.appDelegate.state = uploadData.object(forKey: "state") as? String
                    //                        self.appDelegate.zip = uploadData.object(forKey: "zip") as? String
                    //                        self.appDelegate.country = uploadData.object(forKey: "country") as? String
                    //                        self.appDelegate.mobile = uploadData.object(forKey: "phone") as? String
                    
                    self.appDelegate.userid = uploadData.object(forKey: "userid") as? String
                    self.appDelegate.genuserid = uploadData.object(forKey: "genuserid") as? String
                    
                    //                        self.accountConfirmed = uploadData.object(forKey: "accountConfirmed") as? String
                    //                        self.paymentConfirmed = uploadData.object(forKey: "paymentConfirmed") as? String
                    
                    self.appDelegate.usertype = uploadData.object(forKey: "usertype") as? String
                    
                    if uploadData.object(forKey: "code") as? String != nil
                    {
                        self.appDelegate.referralCode = uploadData.object(forKey: "code") as? String
                    }
                    else
                    {
                        self.appDelegate.referralCode = "undefined"
                    }
                    
                    //                        self.prefs.setValue(self.appDelegate.firstname , forKey: "firstname")
                    //                        self.prefs.setValue(self.appDelegate.lastname , forKey: "lastname")
                    //                        self.prefs.setValue(self.appDelegate.email , forKey: "email")
                    //                        self.prefs.setValue(self.appDelegate.username , forKey: "username")
                    
                    //NotificationCenter.default.post(name: Notification.Name("reloadMenu"), object: nil)
                    
                    print("login usertype: \(self.appDelegate.usertype!)")
                    print("login userid: \(self.appDelegate.userid!)")
                    print("login genuserid: \(self.appDelegate.genuserid!)")
                }
                
                DispatchQueue.main.sync(execute: {
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    if self.status != nil && self.status == "Logged in" {
                        
                        self.isNewUser = false
                        
                        Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.loggedIn), userInfo: nil, repeats: false)
                    }
                    else
                    {
                        print("invalid")
                        self.showBasicAlert(string: self.status!)
                    }
                })
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
                
                DispatchQueue.main.sync(execute: {
                    
                    self.activityView.stopAnimating()
                    self.activityView.isHidden = true
                    
                    let alert = UIAlertController(title: "Login Error", message: err.description, preferredStyle: UIAlertControllerStyle.alert)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                        }
                    }))
                })
            }
            
        }.resume()
    }
    
    func logUserData() {
        
        //get saved user data
    }    
    
    // MARK: Authentication
    
    func login(username: String, password : String?) {
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.crWarmGray
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        let urlString = "\(appDelegate.serverDestination!)loginJSON.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        //UIDevice.current.identifierForVendor!.uuidString
        
        let paramString = "username=\(usernameTxt.text!)&password=\(passwordTxt.text!)&devStatus=\(appDelegate.devStage!)"
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        print("login decryptParam: \(paramString)")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            //print("Entered the completionHandler: \(response)")
            //var err: NSError?
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                print("login dataDict: \(dataDict)")
                
                let uploadData = dataDict.object(forKey: "loginData") as! NSDictionary
                
                if (uploadData != nil)
                {
                    self.status = uploadData.object(forKey: "status") as? String
                    
                    if self.status != nil && self.status == "Logged in" {
                        
                        self.appDelegate.firstname = uploadData.object(forKey: "firstname") as? String
                        self.appDelegate.lastname = uploadData.object(forKey: "lastname") as? String
                        self.appDelegate.username = uploadData.object(forKey: "username") as? String
                        self.appDelegate.email = uploadData.object(forKey: "email") as? String
//                        self.appDelegate.city = uploadData.object(forKey: "city") as? String
//                        self.appDelegate.state = uploadData.object(forKey: "state") as? String
//                        self.appDelegate.zip = uploadData.object(forKey: "zip") as? String
//                        self.appDelegate.country = uploadData.object(forKey: "country") as? String
//                        self.appDelegate.mobile = uploadData.object(forKey: "phone") as? String
                        
                        self.appDelegate.userid = uploadData.object(forKey: "userid") as? String
                        self.appDelegate.genuserid = uploadData.object(forKey: "genuserid") as? String
                        self.appDelegate.profileImg = uploadData.object(forKey: "userimage") as? String
                        
                        
                        self.appDelegate.dob = uploadData.object(forKey: "dob") as? String
                        
                        self.accountConfirmed = uploadData.object(forKey: "accountconfirmed") as? String
                        
                        self.appDelegate.credits = uploadData.object(forKey: "credits") as? String
                        
                        self.basicInfoCompleted = uploadData.object(forKey: "basicinfocompleted") as? String
                        
                        //                        appDelegate.paymentConfirmed = uploadData.object(forKey: "paymentConfirmed") as? String
                        
                        self.appDelegate.usertype = uploadData.object(forKey: "usertype") as? String
                        
                        if uploadData.object(forKey: "code") as? String != nil
                        {
                            self.appDelegate.referralCode = uploadData.object(forKey: "code") as? String
                        }
                        else
                        {
                            self.appDelegate.referralCode = "undefined"
                        }
                        
                        if self.appDelegate.devicetoken != nil
                        {
                            self.updateDeviceToken()
                        }
                        
                        
//                        if uploadData.object(forKey: "gender") as? String != nil
//                        {
//                            self.appDelegate.gender = Int((uploadData.object(forKey: "gender") as? String)!)
//                        }
                        
                        
                        //NotificationCenter.default.post(name: Notification.Name("reloadMenu"), object: nil)
                        
                        print("login usertype: \(self.appDelegate.usertype!)")
                        print("login userid: \(self.appDelegate.userid!)")
                        print("login genuserid: \(self.appDelegate.genuserid!)")
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        
                        if self.status != nil && self.status == "Logged in" {
                            
                            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.loggedIn), userInfo: nil, repeats: false)
                        }
                        else
                        {
                            print("invalid")
                            
                            //self.logout ()
                            self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
                            self.submitBtn.isEnabled = true
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            self.showBasicAlert(string: self.status!)
                        }
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
                
                DispatchQueue.main.sync(execute: {
                    
                    self.activityView.stopAnimating()
                    self.activityView.isHidden = true
                    self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
                    self.submitBtn.isEnabled = true
                    
                    let alert = UIAlertController(title: "Login Error", message: err.description, preferredStyle: UIAlertControllerStyle.alert)
                    
                    self.present(alert, animated: true, completion: nil)
                    
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { action in
                        switch action.style{
                        case .default:
                            print("default")
                            
                        case .cancel:
                            print("cancel")
                            
                        case .destructive:
                            print("destructive")
                        }
                    }))
                })
            }
            
        }.resume()
    }
    
    @objc func loggedIn () {
        
        activityView.isHidden = true
        activityView.stopAnimating()
        
        appDelegate.loggedIn = true
        appDelegate.password = passwordTxt.text
        
//        if self.appDelegate.firstname != nil {
//            self.prefs.setValue(self.appDelegate.firstname , forKey: "firstname")
//        }
//        if self.appDelegate.lastname != nil {
//            self.prefs.setValue(self.appDelegate.lastname , forKey: "lastname")
//        }
        if self.appDelegate.username != nil {
            self.prefs.setValue(self.appDelegate.username , forKey: "username")
        }
        if self.appDelegate.email != nil {
            self.prefs.setValue(self.appDelegate.email , forKey: "email")
        }
        if self.appDelegate.password != nil {
            self.prefs.setValue(self.appDelegate.password , forKey: "password")
        }
        if self.appDelegate.credits != nil {
            self.prefs.setValue(self.appDelegate.credits , forKey: "credits")
        }
//        if self.appDelegate.city != nil {
//            self.prefs.setValue(self.appDelegate.city , forKey: "city")
//        }
//        if self.appDelegate.state != nil {
//            self.prefs.setValue(self.appDelegate.state , forKey: "state")
//        }
//        if self.appDelegate.zip != nil {
//            self.prefs.setValue(self.appDelegate.zip , forKey: "zip")
//        }
//        if self.appDelegate.country != nil {
//            self.prefs.setValue(self.appDelegate.country , forKey: "country")
//        }
//        if self.appDelegate.mobile != nil {
//            self.prefs.setValue(self.appDelegate.mobile , forKey: "mobile")
//        }
        
        if self.appDelegate.userid != nil {
            self.prefs.setValue(self.appDelegate.userid , forKey: "userid")
        }
        if self.appDelegate.genuserid != nil {
            self.prefs.setValue(self.appDelegate.genuserid , forKey: "genuserid")
        }
        if self.appDelegate.profileImg != nil {
            self.prefs.setValue(self.appDelegate.profileImg , forKey: "profileImg")
        }
        
        if self.appDelegate.referralCode != nil {
            self.prefs.setValue(self.appDelegate.referralCode , forKey: "referralCode")
        }
        
        //appDelegate.paymentConfirmed = prefs.string(forKey: "paymentConfirmed")
        
        if self.appDelegate.usertype != nil {
            self.prefs.setValue(self.appDelegate.usertype , forKey: "usertype")
        }
        
//        if self.appDelegate.dob != nil {
//            self.prefs.setValue(self.appDelegate.dob , forKey: "dob")
//        }
//
//        if self.appDelegate.gender != nil {
//            self.prefs.setValue(self.appDelegate.gender , forKey: "gender")
//        }
        
        
        prefs.synchronize()
        
        self.view.endEditing(true)
        
        self.isNewUser = false
        
//        if accountConfirmed == "1" && basicInfoCompleted == "1"
//        {
//            self.performSegue(withIdentifier: "login", sender: self)
//        }
//        else
//        {
//            self.performSegue(withIdentifier: "AddInfo", sender: self)
//        }
        
        self.performSegue(withIdentifier: "login", sender: self)
    }
    
    func checkAutoLogin ()-> Bool {
        
        if let username = prefs.string(forKey: "username"), let _ = prefs.string(forKey: "password"), let userid = prefs.string(forKey: "userid")
        {
            usernameTxt.text = username
            //passwordTxt.text = password
            
            //login(username: username,password: password)
            
            //            prefs.setValue("aport.png", forKey: "profileImg")
            //            prefs.setValue("a", forKey: "firstname")
            //            prefs.setValue("port", forKey: "lastname")
            //
            //            prefs.synchronize()
            
            
            if prefs.string(forKey: "genuserid") != nil
            {
                self.appDelegate.genuserid = prefs.string(forKey: "genuserid")
            }
            if prefs.string(forKey: "usertype") != nil
            {
                self.appDelegate.usertype = prefs.string(forKey: "usertype")
            }
            if prefs.string(forKey: "credits") != nil
            {
                self.appDelegate.credits = prefs.string(forKey: "credits")
            }
            
            if prefs.string(forKey: "firstname") != nil
            {
                self.appDelegate.firstname = prefs.string(forKey: "firstname")
            }
            if prefs.string(forKey: "lastname") != nil
            {
                self.appDelegate.lastname = prefs.string(forKey: "lastname")
            }
            if prefs.string(forKey: "username") != nil
            {
                self.appDelegate.username = prefs.string(forKey: "username")
            }
            if prefs.string(forKey: "email") != nil
            {
                self.appDelegate.email = prefs.string(forKey: "email")
            }
//            if prefs.string(forKey: "city") != nil
//            {
//                self.appDelegate.city = prefs.string(forKey: "city")
//            }
//            if prefs.string(forKey: "state") != nil
//            {
//                self.appDelegate.state = prefs.string(forKey: "state")
//            }
//            if prefs.string(forKey: "zip") != nil
//            {
//                self.appDelegate.zip = prefs.string(forKey: "zip")
//            }
//            if prefs.string(forKey: "country") != nil
//            {
//                self.appDelegate.country = prefs.string(forKey: "country")
//            }
//            if prefs.string(forKey: "mobile") != nil
//            {
//                self.appDelegate.mobile = prefs.string(forKey: "mobile")
//            }
            if prefs.string(forKey: "userid") != nil
            {
                self.appDelegate.userid = userid
            }
            if prefs.string(forKey: "profileImg") != nil
            {
                self.appDelegate.profileImg = prefs.string(forKey: "profileImg")
            }
            if prefs.string(forKey: "accountConfirmed") != nil
            {
                self.accountConfirmed = prefs.string(forKey: "accountconfirmed")
            }
            if prefs.string(forKey: "basicInfoCompleted") != nil
            {
                self.basicInfoCompleted = prefs.string(forKey: "basicinfocompleted")
            }
            
            //                        appDelegate.paymentConfirmed = prefs.string(forKey: "paymentConfirmed")
            
            if prefs.string(forKey: "usertype") != nil
            {
                self.appDelegate.usertype = prefs.string(forKey: "usertype")
            }
            
            if prefs.string(forKey: "referralCode") != nil
            {
                self.appDelegate.referralCode = prefs.string(forKey: "referralCode")
            }
            else
            {
                self.appDelegate.referralCode = "undefined"
            }
            
            if self.appDelegate.devicetoken != nil
            {
                self.updateDeviceToken()
            }
            
            print("userid: \(appDelegate.userid!)")
            //print("genuserid: \(appDelegate.genuserid!)")
            
            return true
        }
        
        return false
    }
    
    @objc func udpateTokenNotification (notification: NSNotification) {
        
        updateDeviceToken()
    }
    
    func debug () {
        
        //logout()
        
        //usernameTxt.text = "ridley1224b"
        //emailTxt.text = "ridleytech@gmail.com"
        
//        usernameTxt.text = "aport2"
//        emailTxt.text = "aport2@gmail.com"
        
        let randomEmail = appDelegate.randomString(length: 5)
        
        usernameTxt.text = randomEmail
        emailTxt.text = "\(randomEmail)@gmail.com"
        
        usernameTxt.text = "aport"
        emailTxt.text = "aport@gmail.com"
        passwordTxt.text = "1111"
        
        let modelName = UIDevice.modelName
        
        if appDelegate.debug == false && !modelName.contains("Simulator") && modelName.contains("iPad")
        {
            usernameTxt.text = "crichardson"
            emailTxt.text = "crichardson@gmail.com"
            passwordTxt.text = "1111"
        }
        else if appDelegate.debug == false && !modelName.contains("Simulator") && modelName.contains("iPhone")
        {
            usernameTxt.text = "acosta"
            emailTxt.text = "acosta@gmail.com"
            passwordTxt.text = "1111"
        }
        
        usernameTxt.text = "ridley1224"
        emailTxt.text = "registerrt1224@gmail.com"
        passwordTxt.text = "1111"
        
        usernameTxt.text = "ridleytech"
        emailTxt.text = "ridleytech@gmail.com"
        passwordTxt.text = "1111"
        
//        usernameTxt.text = "avamaxwell"
//        emailTxt.text = "ridleytech@gmail.com"
//        passwordTxt.text = "1111"
        
//        if modelName.contains("iPhone 5")
//        {
////            sv.frame = CGRect.init(x: 0, y: sv.frame.origin.y, width: view.frame.width, height: sv.frame.height)
////            sv.contentSize = CGSize.init(width: view.frame.width, height: 1300)
//        }
       
        usernameLbl.isHidden = false
        usernameLblHeight.constant = 18

        emailLbl.isHidden = false
        emailLblHeight.constant = 18

        passwordLbl.isHidden = false
        passwordLblHeight.constant = 18
        
        submitBtn.isEnabled = true
        loginBtn.isEnabled = true
        
        //submitBtn.backgroundColor = appDelegate.crLightBlue
        submitBtn.backgroundColor = appDelegate.crLightBlue
    }
    
    func listFiles2() {
        
        let filemgr = FileManager.default
        
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)
        
        //let docsURL = dirPaths[0]
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        print("documentsDirectory: \(documentsDirectory)")
        
        do {
            
            let filelist = try filemgr.contentsOfDirectory(atPath: "/")
            
            for filename in filelist {
                
                print("filename: \(filename)")
            }
            
        } catch let error {
            
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func listFilesFromDocumentsFolder()
    {
        print("list files")
        
        let filemgr = FileManager.default
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        
        do {
            
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsDirectory!, includingPropertiesForKeys: nil, options: [])
            
            for i in 0 ..< directoryContents.count
            {
                let obj = directoryContents[i] as URL
                
                print("file: \(obj)")
                
                try! filemgr.removeItem(at: obj)
            }
        } catch {
            
            print("Could not search for urls of files in documents directory: \(error)")
        }
    }
    
    @objc func logout1 (notification : NSNotification)
    {
        print("logout notification")
        logout()
    }
    
    func logout () {
        
        self.appDelegate.initLoaded = false
        self.appDelegate.loggedIn = false
        
//        prefs.removeObject(forKey: "firstname")
//        prefs.removeObject(forKey: "lastname")
        prefs.removeObject(forKey: "username")
        prefs.removeObject(forKey: "password")
        prefs.removeObject(forKey: "email")
//        prefs.removeObject(forKey: "city")
//        prefs.removeObject(forKey: "state")
//        prefs.removeObject(forKey: "zip")
//        prefs.removeObject(forKey: "country")
//        prefs.removeObject(forKey: "mobile")
        prefs.removeObject(forKey: "userid")
        prefs.removeObject(forKey: "genuserid")
        prefs.removeObject(forKey: "profileImg")
        prefs.removeObject(forKey: "referralCode")
        prefs.removeObject(forKey: "basicInfoCompleted")
        prefs.removeObject(forKey: "accountConfirmed")
        prefs.removeObject(forKey: "credits")
        
        prefs.removeObject(forKey: "cloudVersion")
        prefs.removeObject(forKey: "upgraded")
        prefs.removeObject(forKey: "nonConsumablePurchaseMade")
//
//        appDelegate.fullVersion = nil
        
        prefs.synchronize()
        
//        appDelegate.firstname = nil
//        appDelegate.lastname = nil
        appDelegate.username = nil
        appDelegate.email = nil
//        appDelegate.city = nil
//        appDelegate.state = nil
//        appDelegate.zip = nil
//        appDelegate.country = nil
//        appDelegate.mobile = nil
        appDelegate.userid = nil
        appDelegate.genuserid = nil
        appDelegate.profileImg = nil
        appDelegate.referralCode = nil
        
        emailTxt.text = ""
        usernameTxt.text = ""
        passwordTxt.text = ""
        
        validateInputs()
        
        //self.navigationController?.popToRootViewController(animated: true)
        
        for controller in self.navigationController!.viewControllers as Array {
            
            if controller.isKind(of: Login.self) {
                
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation])
    {
        //print("didUpdateLocations")
        
        let latestLocation: CLLocation = locations[locations.count - 1]
        
        if startLocation == nil {
            startLocation = latestLocation
        }
        
        //let distanceBetween: CLLocationDistance = latestLocation.distance(from: startLocation)
        
        appDelegate.lat = "\(latestLocation.coordinate.latitude)"
        appDelegate.lng = "\(latestLocation.coordinate.longitude)"
    }
    
    // MARK: Actions
    
    @IBAction func showPassword(_ sender: Any) {
        
        if passwordTxt.isSecureTextEntry
        {
            passwordTxt.isSecureTextEntry = false
            viewPasswordBtn.setBackgroundImage(UIImage.init(named: "orange-closed"), for: .normal)
        }
        else
        {
            passwordTxt.isSecureTextEntry = true
            viewPasswordBtn.setBackgroundImage(UIImage.init(named: "orange-open"), for: .normal)
        }
    }
    
    @IBAction func touchIdAction(_ sender: UIButton) {
        
        promptTouchID()
    }
    
    func promptTouchID () {
        
        //https://medium.com/anantha-krishnan-k-g/how-to-add-faceid-touchid-using-swift-4-a220db360bf4
        
        let myContext = LAContext()
        let myLocalizedReasonString = "Login with Touch ID"
        
        var authError: NSError?
        
        if #available(iOS 8.0, macOS 10.12.1, *) {
            
            if myContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &authError) {
                
                myContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString) { success, evaluateError in
                    
                    DispatchQueue.main.async {
                        if success {
                            // User authenticated successfully, take appropriate action
                            //self.successLabel.text = "Awesome!!... User authenticated successfully"
                            print("Awesome!!... User authenticated successfully")
                            
//                            self.touchIDAlert = UIAlertController(title: nil, message: "User authenticated successfully", preferredStyle: UIAlertControllerStyle.alert)
//
//                            self.present(self.touchIDAlert!, animated: true, completion: nil)
                            
                            self.activityView.startAnimating()
                            self.activityView.isHidden = false
                            
                            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(self.touchIDLogin), userInfo: nil, repeats: false)
                            
                        } else {
                            // User did not authenticate successfully, look at error and take appropriate action
                            //self.successLabel.text = "Sorry!!... User did not authenticate successfully"
                            print("Sorry!!... User did not authenticate successfully")
                            
                            self.showBasicAlert(string: "User did not authenticate successfully")
                        }
                    }
                }
            } else {
                
                // Could not evaluate policy; look at authError and present an appropriate message to user
                //successLabel.text = "Sorry!!.. Could not evaluate policy."
                
                print("Ooops!!.. This feature is not supported.")
            }
        } else {
            // Fallback on earlier versions
            
            print("Sorry!!.. Could not evaluate policy.")
            //successLabel.text = "Ooops!!.. This feature is not supported."
        }
    }
    
    @objc func touchIDLogin() {
        
        self.touchIDAlert?.dismiss(animated: true, completion: nil)
        
        if self.checkAutoLogin() == true
        {
            self.performSegue(withIdentifier: "AutoLogin", sender: nil)
        }
        else
        {
            print("no")
        }
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
        
        validateInputs()
    }
    
    @IBAction func createAccount(_ sender: Any) {
        
        isNewUser = true
        
//        if showingRestaurant == true
//        {
//            self.performSegue(withIdentifier: "CreateVenueProfile", sender: self)
//        }
//        else
//        {
//            self.performSegue(withIdentifier: "CreateGuestProfile", sender: self)
//        }
    }
    
    @IBAction func login(_ sender: Any) {
        
        dismissKeyboard()
        
        if appDelegate.isInternetAvailable() || appDelegate.debug == true
        {
            for i : Int in 0 ..< (inputList.count)
            {
                let textField = inputList[i] as! UITextField
                
                if textField.text == ""
                {
                    showBasicAlert(string:textField.restorationIdentifier!)
                    
                    return
                }
            }
            
            login(username: usernameTxt.text!,password: passwordTxt.text)
        }
        else
        {
            self.showBasicAlert(string: "Please check your internet connection")
        }
    }
    
    func showBasicAlert(string:String)
    {
        let alert = UIAlertController(title: nil, message: string, preferredStyle: UIAlertControllerStyle.alert)
        
        self.present(alert, animated: true, completion: nil)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style {
                
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
            }
        }))
    }
    
    @IBAction func loginFB(_ sender: Any) {
        
        //http://www.oodlestechnologies.com/blogs/How-To-Integrate-Facebook-iOS-Application-In-swift-4
        
        FacebookSignInManager.basicInfoWithCompletionHandler(self) { (dataDictionary:Dictionary<String, AnyObject>?, error:NSError?) -> Void in
            
            if dataDictionary != nil
            {
                print("dataDictionary: \(dataDictionary!)")
                
                self.appDelegate.firstname = dataDictionary!["first_name"] as? String
                self.appDelegate.lastname = dataDictionary!["last_name"] as? String
                self.appDelegate.email = dataDictionary!["email"] as? String
                self.appDelegate.fbID = dataDictionary!["id"] as? String
                let pic = dataDictionary!["picture"] as! NSDictionary
                let data = pic["data"] as! NSDictionary
                
                self.appDelegate.profileImg = data["url"] as? String
                self.appDelegate.isAuthenticated = true
                
                self.prefs.setValue(self.appDelegate.fbID , forKey: "fbid")
                self.prefs.setValue(self.appDelegate.profileImg , forKey: "profileImg")
                
                self.checkFBCreds()
            }
        }
    }
    
    @IBAction func loginTwitter(_ sender: Any) {
        
    }
    
    @IBAction func loginEmail(_ sender: Any) {
        
    }
    
    @IBAction func showLogin(_ sender: Any) {
        
        showLogin()
    }
    
    func showLogin () {
        
        isLoggingIn = true
        
        emailLbl.isHidden = true
        emailTxt.isHidden = true
        emailUnderscoreView.isHidden = true
        
        emailTxtHeight.constant = 0
        emailLblHeight.constant = 0
        emailUnderscoreHeight.constant = 0
        
        emailTxtTopPadding.constant = 0
        passwordTxtTopPadding.constant = 0
        passwordLblTopPadding.constant = 0
        
        let attributedString = NSMutableAttributedString(string: "LOGIN", attributes: [
            .font: UIFont(name: "Avenir-Heavy", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        loginBtn.setAttributedTitle(attributedString, for: .normal)
        
        let attributedString2 = NSMutableAttributedString(string: "SIGNUP", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        showSignupBtn.setAttributedTitle(attributedString2, for: .normal)
        
        if usernameTxt.text != ""
        {
            usernameLbl.isHidden = false
            usernameLblHeight.constant = 18
        }
        if passwordTxt.text != ""
        {
            passwordLbl.isHidden = false
            passwordLblHeight.constant = 18
        }
        
        validateInputs()
    }
    
    @IBAction func showSignup(_ sender: Any) {
        
        showSignup()
    }
    
    func showSignup() {
        
        isLoggingIn = false
        
        usernameLblHeight.constant = 0
        emailLblHeight.constant = 0
        passwordLblHeight.constant = 0
        
        emailTxt.isHidden = false
        emailUnderscoreView.isHidden = false
        
        emailTxtHeight.constant = 30
        //emailLblHeight.constant = 18
        emailUnderscoreHeight.constant = 1
        
        emailTxtTopPadding.constant = 5
        passwordTxtTopPadding.constant = 5
        passwordLblTopPadding.constant = 20
        
        let attributedString = NSMutableAttributedString(string: "LOGIN", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        loginBtn.setAttributedTitle(attributedString, for: .normal)
        
        let attributedString2 = NSMutableAttributedString(string: "SIGNUP", attributes: [
            .font: UIFont(name: "Avenir-Heavy", size: 20.0)!,
            .foregroundColor: UIColor.white
            ])
        
        showSignupBtn.setAttributedTitle(attributedString2, for: .normal)
        
        if usernameTxt.text != ""
        {
            usernameLbl.isHidden = false
            usernameLblHeight.constant = 18
        }
        if emailTxt.text != ""
        {
            emailLbl.isHidden = false
            emailLblHeight.constant = 18
        }
        if passwordTxt.text != ""
        {
            passwordLbl.isHidden = false
            passwordLblHeight.constant = 18
        }
        
        validateInputs()
    }
    
    @IBAction func clearEmail(_ sender: Any) {
        
        emailTxt.text = ""
    }
    
    @IBAction func submit(_ sender: Any) {
        
        dismissKeyboard()
        
        if isLoggingIn == true
        {
            login(username: usernameTxt.text!,password: passwordTxt.text)
        }
        else
        {
            uploadUserData()
        }
    }
    
    func updateDeviceToken() {
        
        let urlString = "\(appDelegate.serverDestination!)updateToken.php"
        
        print("device token urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        //UIDevice.current.identifierForVendor!.uuidString
        
        let paramString = "uid=\(appDelegate.userid!)&deviceid=\(appDelegate.devicetoken!)&devStatus=\(appDelegate.devStage!)"
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        print("update token param: \(paramString)")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            //print("Entered the completionHandler: \(response)")
            
            //var err: NSError?
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print("loginData: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                print("dataDict: \(dataDict)")
                
                let uploadData : NSDictionary = dataDict.object(forKey: "tokenData") as! NSDictionary
                
                if (uploadData != nil)
                {
                    self.status = uploadData.object(forKey: "status") as? String
                    
                    DispatchQueue.main.sync(execute: {
                        
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
                
                DispatchQueue.main.sync(execute: {
                    
                })
            }
            
        }.resume()
    }
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "CreateGuestProfile"
        {
//            let destination = segue.destination as! MyProfileViewController
//            destination.isNewUser = isNewUser
//
//            if usingFB == false
//            {
//                appDelegate.firstname = nil
//                appDelegate.lastname = nil
//                appDelegate.email = nil
//            }
//
//            usingFB = false
        }
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }

    @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    // MARK: Textfield
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool{
        
        let disallowedCharacterSet = NSCharacterSet()
        
        let maxLength = 35
        
        let currentString: NSString = textField.text! as NSString
        
        var result = true
        
        let replacementStringIsLegal = string.rangeOfCharacter(from: disallowedCharacterSet as CharacterSet) == nil
        
        let newString: NSString =
            currentString.replacingCharacters(in: range, with: string) as NSString
        
        if newString.length <= maxLength
        {
            result = replacementStringIsLegal
        }
        else
        {
            result = false
        }
        
        validateInputs()
        
        //return newString.length <= maxLength
        
        return result
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.restorationIdentifier == "username" && textField.text != ""
        {
            usernameLbl.isHidden = false
            usernameLblHeight.constant = 18
        }
        else if textField.restorationIdentifier == "email" && textField.text != ""
        {
            emailLbl.isHidden = false
            emailLblHeight.constant = 18
        }
        else if textField.restorationIdentifier == "password" && textField.text != ""
        {
            passwordLbl.isHidden = false
            passwordLblHeight.constant = 18
        }
        
        validateInputs()
    }
    
    func isValidEmail(emailID:String) -> Bool {
        
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: emailID)
    }
    
    func uploadUserData() {
        
        if !isValidEmail(emailID: emailTxt.text!)
        {
            showBasicAlert(string: "Please enter a valid email address")
            return
        }
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadUserData")
        
        let urlString = "\(appDelegate.serverDestination!)updateProfile.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var paramString = "email=\(emailTxt.text!)&username=\(usernameTxt.text!)&password=\(passwordTxt.text!)&deviceid=\(UIDevice.current.identifierForVendor!.uuidString)&signup=true&devStatus=\(appDelegate.devStage!)&code=\(appDelegate.randomString(length: 5))"
        
        if let string = appDelegate.fbID, !string.isEmpty {
            
            /* string is not blank */
            
            print("fbID not blank. update")
            
            paramString = "\(paramString)&fbid=\(appDelegate.fbID!)&devStatus=\(appDelegate.devStage!)"
        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
        do {
            
            let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
            
            print("add user jsonResult: \(jsonResult)")
            
            let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
            
            if dataDict["userData"]! is NSNull
            {
                print("no user")
                
                DispatchQueue.main.sync(execute: {
                    
                    self.showError(status: "error")
                })
            }
            else
            {
                let userDict : NSDictionary = dataDict["userData"] as! NSDictionary
                
                let status : String = userDict["status"] as! String
                
                print("status: \(status)")
                
                if (status == "user saved" || status == "user updated")
                {
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                        self.submitBtn.isEnabled = true
                        //self.submitBtn.alpha = 1
                        
                        self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
                        
                        self.loginBtn.isEnabled = true
                        self.loginBtn.alpha = 1
                        
                        if (status == "user saved")
                        {
                            let userid : NSNumber = userDict["userid"] as! NSNumber
                            self.appDelegate.userid = "\(userid)"
                            self.isNewUser = true
                            self.appDelegate.email = self.emailTxt.text!
                        }
                        
                        self.prefs.setValue(self.usernameTxt.text! , forKey: "username")
                        self.prefs.setValue(self.emailTxt.text! , forKey: "email")
                        self.prefs.setValue(self.passwordTxt.text! , forKey: "password")
                        
                        self.prefs.synchronize()
                        
                        if self.isNewUser == true
                        {
                            self.dismissKeyboard()
                            self.usernameTxt.text = ""
                            self.emailTxt.text = ""
                            self.passwordTxt.text = ""
                            self.performSegue(withIdentifier: "signupConfirmation", sender: self)
                        }
                    })
                }
                else
                {
                    DispatchQueue.main.sync(execute: {
                        
                        self.showError(status: status)
                    })
                }
            }
        }
        catch let err as NSError
        {
            print("error: \(err.description)")
        }
        
        }.resume()
    }
    
    func showError (status: String) {
        
        self.activityView.isHidden = true
        self.activityView.stopAnimating()
        
        self.submitBtn.isEnabled = true
        //self.submitBtn.alpha = 1
        
        self.loginBtn.isEnabled = true
        self.loginBtn.alpha = 1
        
        self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
        
        self.showBasicAlert(string: status)
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
