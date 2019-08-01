//
//  BasicProfileInfo.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/19/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class BasicProfileInfo: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let prefs = UserDefaults.standard
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var pregnantBtn: UIButton!
    
    @IBOutlet weak var breastfeedingBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var pregnantView: UIView!
    @IBOutlet weak var instructionsLbl: UILabel!
    @IBOutlet weak var genderSegment: UISegmentedControl!
    
    var isPregnant : Bool?
    var isBreastfeeding : Bool?
    
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var fullnameTxt: UITextField!
    
    @IBOutlet weak var dobLbl: UILabel!
    @IBOutlet weak var dobTxt: UITextField!
    
    @IBOutlet weak var dobTxtTopPadding: NSLayoutConstraint!
    @IBOutlet weak var fullnameTxtTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var dateView: UIView!
    
    var selectedDate : String?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        appDelegate.signingUp = true

        isPregnant = false
        isBreastfeeding = false
        
        activityView.isHidden = true
        dateView.isHidden = true
        
        dobTxtTopPadding.constant = 0
        //fullnameTxtTopPadding.constant = 0
        
        //years in days * seconds in a day
        
        let d = Date(timeInterval: -6570*86400, since: NSDate() as Date)
        
        //dobPicker.setDate(NSDate() as Date, animated: false)
        dobPicker.setDate(d, animated: false)
        
        pregnantView.isHidden = true
        fullnameLbl.isHidden = true
        dobLbl.isHidden = true
        
        let attributedString = NSMutableAttributedString(string: "* You can change this from your Account Settings", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 12.0)!,
            .foregroundColor: appDelegate.crWarmGray
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Heavy", size: 12.0)!, range: NSRange(location: 32, length: 16))
        
        instructionsLbl.attributedText = attributedString
        
        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            btnItem]
        
        numberToolbar.sizeToFit()
        
        fullnameTxt.inputAccessoryView = numberToolbar
        dobTxt.inputAccessoryView = numberToolbar
        
        //debug()
    }
    
    func debug() {
        
        fullnameTxt.text = "\(appDelegate.randomString(length: 5)) \(appDelegate.randomString(length: 5))"
        
        selectDate()
    }    
    
    @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    func selectDate () {
        
        selectedDate = appDelegate.convertDateToSQLDate(date: dobPicker.date)
        
        let df = DateFormatter()
        df.dateFormat = "MM/d/yy"
        
        let displayString = df.string(from: dobPicker.date)
        
        dobTxt.text = displayString
        dateView.isHidden = true
        
        
        //        if editingIndex == 0
        //        {
        //            heightTxt.text = "\(selectedFoot!) ft, \(selectedInch!) in"
        //        }
        //        else if editingIndex == 1
        //        {           heightWeightPicker.isHidden  = false
        //
        //            weightTxt.text = "\(selectedWeight!) lbs"
        //        }
        //        else
        //        {
        //            dobLbl.isHidden = false
        //
        //            selectedDateString = appDelegate.convertDateToSQLDate(date: dobPicker.date)
        //            selectedDate = dobPicker.date
        //
        //            let df = DateFormatter()
        //            df.dateFormat = "MM/d/yy"
        //
        //            let displayString = df.string(from: dobPicker.date)
        //
        //            dobTxt.text = displayString
        //            pickersView.isHidden = true
        //        }
    }
    
    @IBAction func selectPicker(_ sender: Any) {
        
        selectDate()
    }
    
    @IBAction func showDatePopup(_ sender: Any) {
        
        dismissKeyboard()
        
        dateView.isHidden = false
    }
    
    @IBAction func selectCusines(_ sender: Any) {
        
        //self.performSegue(withIdentifier: "SelectCuisines", sender: self)
        
        if fullnameTxt.text == ""
        {
            self.showBasicAlert(string: "Please Enter Full Name")
            return
        }
        
        if dobTxt.text == ""
        {
            self.showBasicAlert(string: "Please Enter Date of Birth")
            return
        }
        
        uploadUserData()
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
    
    @IBAction func selectDate(_ sender: Any) {
        
        selectedDate = appDelegate.convertDateToSQLDate(date: dobPicker.date)
        
        appDelegate.dob = selectedDate
        
        let df = DateFormatter()
        df.dateFormat = "MM/d/yy"
        
        let displayString = df.string(from: dobPicker.date)
        
        dobTxt.text = displayString
        dateView.isHidden = true
    }
    
    @IBAction func managePregnant(_ sender: Any) {
        
        if isPregnant == true
        {
            pregnantBtn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            isPregnant = false
        }
        else
        {
            pregnantBtn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            isPregnant = true
        }
    }
    
    @IBAction func manageBreastfeeding(_ sender: Any) {
        
        if isBreastfeeding == true
        {
            breastfeedingBtn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            isBreastfeeding = false
        }
        else
        {
            breastfeedingBtn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            isBreastfeeding = true
        }
    }
    
    @IBAction func manageGender(_ sender: Any) {
        
        if genderSegment.selectedSegmentIndex != 0
        {
            pregnantView.isHidden = false
        }
        else
        {
            pregnantView.isHidden = true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.restorationIdentifier == "fullname" && textField.text != ""
        {
            fullnameLbl.isHidden = false
            //usernameLblHeight.constant = 18
            
            //fullnameTxtTopPadding.constant = 0
        }
        else if textField.restorationIdentifier == "dob" && textField.text != ""
        {
            dobLbl.isHidden = false
            //emailLblHeight.constant = 18
            dobTxtTopPadding.constant = 5
        }
    }
    
    func uploadUserData() {
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadUserData")
        
        let urlString = "\(appDelegate.serverDestination!)updateProfile.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "fullname=\(fullnameTxt.text!)&dob=\(selectedDate!)&gender=\(genderSegment.selectedSegmentIndex)&isbreastfeeding=\(isBreastfeeding!)&ispregnant=\(isPregnant!)&basicprofile=true&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
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
                }
                else
                {
                    let userDict : NSDictionary = dataDict["userData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "basic info saved")
                    {
                        let name = self.fullnameTxt.text
                        
                        let nameParts = name?.split(separator: " ")
                        
                        if nameParts!.count > 1
                        {
                            self.appDelegate.firstname = String(nameParts![0])
                            self.appDelegate.lastname = String(nameParts![1])
                        }
                        else
                        {
                            self.appDelegate.firstname = String(nameParts![0])
                            self.appDelegate.lastname = ""
                        }
                        
                        self.prefs.setValue(self.appDelegate.firstname, forKey: "firstname")
                        self.prefs.setValue(self.appDelegate.lastname, forKey: "lastname")
                        
                        self.prefs.synchronize()
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.performSegue(withIdentifier: "SelectCuisines", sender: self)
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            //self.showBasicAlert(string: status)
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
