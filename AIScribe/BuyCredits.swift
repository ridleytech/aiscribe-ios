//
//  BuyCredits.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/9/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class BuyCredits: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let prefs = UserDefaults.standard
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var creditsTxt: UITextField!
    
    @IBOutlet weak var firstnameLbl: UILabel!
    @IBOutlet weak var lastnameLbl: UILabel!
    
    @IBOutlet weak var firstnameTxt: UITextField!
    @IBOutlet weak var lastnameTxt: UITextField!
    
    @IBOutlet weak var cardnoLbl: UILabel!
    @IBOutlet weak var cardnoTxt: UITextField!
    
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var addressTxt: UITextField!
    
    @IBOutlet weak var cityLbl: UILabel!
    @IBOutlet weak var cityTxt: UITextField!
    
    @IBOutlet weak var stateLbl: UILabel!
    @IBOutlet weak var stateTxt: UITextField!
    
    @IBOutlet weak var zipLbl: UILabel!
    @IBOutlet weak var zipTxt: UITextField!
    
    @IBOutlet weak var countryLbl: UILabel!
    @IBOutlet weak var countryTxt: UITextField!
    
    @IBOutlet weak var expLbl: UILabel!
    @IBOutlet weak var expTxt: UITextField!
    
    @IBOutlet weak var ccvLbl: UILabel!
    @IBOutlet weak var ccvTxt: UITextField!
    
    @IBOutlet weak var lastnameTopPadding: NSLayoutConstraint!
    @IBOutlet weak var firstnameTopPadding: NSLayoutConstraint!
    
    @IBOutlet weak var cardNoPadding: NSLayoutConstraint!
    
    @IBOutlet weak var addressPadding: NSLayoutConstraint!
    
    @IBOutlet weak var cityPadding: NSLayoutConstraint!
    
    @IBOutlet weak var zipPadding: NSLayoutConstraint!
    @IBOutlet weak var statePadding: NSLayoutConstraint!
    
    @IBOutlet weak var countryPadding: NSLayoutConstraint!
    
    @IBOutlet weak var expPadding: NSLayoutConstraint!
    @IBOutlet weak var ccvPadding: NSLayoutConstraint!
    
    @IBOutlet weak var creditsPadding: NSLayoutConstraint!
    
    var validateFields : [UITextField]?
    
    @IBOutlet weak var contentSV: UIScrollView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
        
        firstnameTopPadding.constant = 0
        lastnameTopPadding.constant = 0
        firstnameTopPadding.constant = 0
        cardNoPadding.constant = 0
        addressPadding.constant = 0
        cityPadding.constant = 0
        zipPadding.constant = 0
        statePadding.constant = 0
        countryPadding.constant = 0
        expPadding.constant = 0
        ccvPadding.constant = 0
        //creditsPadding.constant = 0
        
        validateFields = [creditsTxt,firstnameTxt,lastnameTxt, cardnoTxt,addressTxt,cityTxt,stateTxt,zipTxt,countryTxt,expTxt ,ccvTxt]
        
        creditsLbl.isHidden = true
        firstnameLbl.isHidden = true
        lastnameLbl.isHidden = true
        cardnoLbl.isHidden = true
        addressLbl.isHidden = true
        cityLbl.isHidden = true
        stateLbl.isHidden = true
        zipLbl.isHidden = true
        countryLbl.isHidden = true
        expLbl.isHidden = true
        ccvLbl.isHidden = true
        
        expTxt.placeholder = "expiration (12/2019)"
        
        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            btnItem]
        
        numberToolbar.sizeToFit()
        
        creditsTxt.delegate = self
        firstnameTxt.delegate = self
        lastnameTxt.delegate = self
        cardnoTxt.delegate = self
        ccvTxt.delegate = self
        expTxt.delegate = self
        addressTxt.delegate = self
        cityTxt.delegate = self
        stateTxt.delegate = self
        zipTxt.delegate = self
        countryTxt.delegate = self
        
        creditsTxt.inputAccessoryView = numberToolbar
        firstnameTxt.inputAccessoryView = numberToolbar
        lastnameTxt.inputAccessoryView = numberToolbar
        cardnoTxt.inputAccessoryView = numberToolbar
        ccvTxt.inputAccessoryView = numberToolbar
        expTxt.inputAccessoryView = numberToolbar
        addressTxt.inputAccessoryView = numberToolbar
        cityTxt.inputAccessoryView = numberToolbar
        stateTxt.inputAccessoryView = numberToolbar
        zipTxt.inputAccessoryView = numberToolbar
        countryTxt.inputAccessoryView = numberToolbar
        
        creditsTxt.keyboardType = .decimalPad
        cardnoTxt.keyboardType = .numberPad
        ccvTxt.keyboardType = .numberPad
        zipTxt.keyboardType = .numberPad
        
        creditsLbl.isHidden = false
        creditsTxt.text = "10.00"
        
        //debugVals()
    }
    
    func debugVals () {
        
        firstnameTopPadding.constant = 22
        lastnameTopPadding.constant = 22
        cardNoPadding.constant = 22
        addressPadding.constant = 22
        cityPadding.constant = 22
        zipPadding.constant = 22
        statePadding.constant = 22
        countryPadding.constant = 22
        expPadding.constant = 22
        ccvPadding.constant = 22
        
        creditsLbl.isHidden = false
        firstnameLbl.isHidden = false
        lastnameLbl.isHidden = false
        cardnoLbl.isHidden = false
        addressLbl.isHidden = false
        cityLbl.isHidden = false
        stateLbl.isHidden = false
        zipLbl.isHidden = false
        countryLbl.isHidden = false
        expLbl.isHidden = false
        ccvLbl.isHidden = false
    }
    
    override func viewDidLayoutSubviews() {
        
        contentSV.contentSize = CGSize.init(width: contentSV.frame.width, height: 1400)
    }
    
    // MARK: Actions
    
    @IBAction func goBack(_ sender: Any) {
        
        dismiss()
    }
    
    func dismiss() {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitPayment(_ sender: Any) {
        
        for txt in validateFields!
        {
            if txt.text == ""
            {
                self.showBasicAlert(string: "Please enter \(txt.restorationIdentifier!)")
                return
            }
        }
        
        submitPayment()
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
    
    // MARK: Web service
    
    func submitPayment() {
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.gray74
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("submitPayment")
        
        let dataString = "paymentData"
        
        let urlString = "\(appDelegate.serverDestination!)buyCreditsJSON.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "credits=\(creditsTxt.text!)&firstname=\(firstnameTxt.text!)&lastname=\(lastnameTxt.text!)&card_number=\(cardnoTxt.text!)&cvc_number=\(ccvTxt.text!)&exp=\(expTxt.text!)&address=\(addressTxt.text!)&city=\(cityTxt.text!)&state=\(stateTxt.text!)&zip=\(zipTxt.text!)&country=\(countryTxt.text!)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        //paramString = "\(paramString)&basicprofile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("payment jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull
                {
                    print("no payment")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                    self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
                }
                else
                {
                    let userDict : NSDictionary = dataDict[dataString] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    self.appDelegate.credits = userDict["credits"] as? String
                    
                    print("status: \(status)")
                    
                    if (status == "payment successful")
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            NotificationCenter.default.post(name: Notification.Name("updateCredits"), object: self.appDelegate.credits)
                            
                            let alert = UIAlertController(title: nil, message: "Payment Successful", preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                   self.dismiss()
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                }
                            }))
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
                            
                            self.showBasicAlert(string: status)
                        })
                    }
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
                
                self.activityView.isHidden = true
                self.activityView.stopAnimating()
                
                self.submitBtn.isEnabled = true
                self.submitBtn.alpha = 1
                self.submitBtn.backgroundColor = self.appDelegate.crLightBlue
            }
            
        }.resume()
    }
    
    // MARK: Textfield Delegate
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if textField.restorationIdentifier == "First Name" && textField.text != ""
        {
            firstnameLbl.isHidden = false
            firstnameTopPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Last Name" && textField.text != ""
        {
            lastnameLbl.isHidden = false
            lastnameTopPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Card No" && textField.text != ""
        {
            // add length condition
            
            cardnoLbl.isHidden = false
            cardNoPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Address" && textField.text != ""
        {
            addressLbl.isHidden = false
            addressPadding.constant = 22
        }
        else if textField.restorationIdentifier == "City" && textField.text != ""
        {
            cityLbl.isHidden = false
            cityPadding.constant = 22
        }
        else if textField.restorationIdentifier == "State" && textField.text != ""
        {
            stateLbl.isHidden = false
            statePadding.constant = 22
        }
        else if textField.restorationIdentifier == "Zip" && textField.text != ""
        {
            zipLbl.isHidden = false
            zipPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Country" && textField.text != ""
        {
            countryLbl.isHidden = false
            countryPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Expiration Date" && textField.text != ""
        {
            expPadding.constant = 22
            expLbl.isHidden = false
            
            if appDelegate.validateDate(date: textField.text!)
            {
                
            }
            else
            {
                textField.text = ""
                //expPadding.constant = 0
                
                let alert = UIAlertController(title: nil, message: "Invalid Expiration Date", preferredStyle: UIAlertControllerStyle.alert)
                
                self.present(alert, animated: true, completion: nil)
                
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                    switch action.style{
                    case .default:
                        print("default")
                        
                    case .cancel:
                        print("cancel")
                        
                    case .destructive:
                        print("destructive")
                    }
                }))
            }
        }
        else if textField.restorationIdentifier == "CCV" && textField.text != ""
        {
            ccvLbl.isHidden = false
            ccvPadding.constant = 22
        }
        else if textField.restorationIdentifier == "Credits" && textField.text != ""
        {
            // add format condition
            
            if ((textField.text?.doubleValue) != nil)
            {
                creditsLbl.isHidden = false
                creditsPadding.constant = 22
            }
            else
            {
                creditsLbl.isHidden = true
                creditsPadding.constant = 0
                textField.text = "5.00"
            }
        }
    }
    
    // MARK: - Navigation
    
    @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension String {
    struct NumFormatter {
        static let instance = NumberFormatter()
    }
    
    var doubleValue: Double? {
        return NumFormatter.instance.number(from: self)?.doubleValue
    }
    
    var integerValue: Int? {
        return NumFormatter.instance.number(from: self)?.intValue
    }
}
