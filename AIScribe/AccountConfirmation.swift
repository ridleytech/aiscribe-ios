//
//  AccountConfirmation.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/18/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit


class AccountConfirmation: UIViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var instructionsLbl: UILabel!
        
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let attributedString = NSMutableAttributedString(string: "We’ve emailed a verification link to \(appDelegate.email!). Click on the link in the email to finish setting up your account.", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 16.0)!,
            .foregroundColor: appDelegate.crGray
            ])
        
        attributedString.addAttributes([
            .font: UIFont(name: "Avenir-Medium", size: 16.0)!,
            .foregroundColor: UIColor.black
            ], range: NSRange(location: 37, length: appDelegate.email!.characters.count))
        
        instructionsLbl.attributedText = attributedString
        
        let attributedString2 = NSMutableAttributedString(string: "Did not receive verification link? Resend email.", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 14.0)!,
            .foregroundColor: UIColor.gray
            ])
        
        attributedString2.addAttributes([
            .font: UIFont(name: "Avenir-Medium", size: 14.0)!,
            .foregroundColor: appDelegate.crLightBlue
            ], range: NSRange(location: 35, length: 12))
        
        statusLbl.attributedText = attributedString2
    }
    
    @IBAction func returnLogin(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            
            if controller.isKind(of: Login.self) {
                
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//
//        print("viewDidAppear")
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        
//        print("viewWillAppear")
//    }
    
    func checkConfirmation() {
        
        let urlString = "\(appDelegate.serverDestination!)checkConfirmation.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("confirmation check jsonResult: \(jsonResult)")
                
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
                    
                    if (status == "account confirmed")
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.performSegue(withIdentifier: "AddInfo", sender: self)

                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
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
    
    @IBAction func resendEmail(_ sender: Any) {
        
        let urlString = "\(appDelegate.serverDestination!)resendEmail.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "email=\(appDelegate.email!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("resend email jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["emailData"]! is NSNull
                {
                    print("no user")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["emailData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "email sent")
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.showBasicAlert(string: "Email has been resent to \(self.appDelegate.email!)")
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.showBasicAlert(string: "Request could not be completed. Please check your internet connection.")
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
