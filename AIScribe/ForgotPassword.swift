//
//  ForgotPassword.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/18/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class ForgotPassword: UIViewController, UITextFieldDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
        emailTxt.delegate = self
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.crWarmGray
        
        submitBtn.layer.cornerRadius = submitBtn.frame.width/2
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        emailTxt?.inputAccessoryView = keyboardDoneButtonView
        
        //debug()
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func debug () {
        
        emailTxt?.text = "ridleytech@gmail.com"
        submitBtn.isEnabled = true
        
        submitBtn.backgroundColor = appDelegate.crLightBlue
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
        
        if emailTxt.text != ""
        {
            submitBtn.isEnabled = true
            submitBtn.backgroundColor = appDelegate.crLightBlue
        }
    }

    func sendPasswordRequest() {
        
        NotificationCenter.default.post(name: Notification.Name("showResetInstructions"), object: nil)
        
        for controller in self.navigationController!.viewControllers as Array {
            
            if controller.isKind(of: Login.self) {
                
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if emailTxt.text != ""
        {
            submitBtn.isEnabled = true
            submitBtn.backgroundColor = appDelegate.crLightBlue
        }
    }
    
    @IBAction func sendRequest(_ sender: Any) {
        
        if emailTxt.text != ""
        {
            activityView.isHidden = false
            activityView.startAnimating()
            
            let urlString = "\(appDelegate.serverDestination!)passwordRequestJSON.php"
            
            print("urlString: \(urlString)")
            
            let url = URL(string: urlString)
            
            
            var request = URLRequest(url: url!)
            
            request.httpMethod = "POST"
            
            let paramString = "email=\(emailTxt.text!)&devStatus=\(appDelegate.devStage!)&mobile=true&devStatus=\(appDelegate.devStage!)"
            
            request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            
            //print("decryptParam: \(paramString)")
            
            let session = URLSession.shared
            
            session.dataTask(with: request) {data, response, err in
                
                //print("Entered the completionHandler: \(response)")
                
                //var err: NSError?
                
                do {
                    
                    let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                    
                    print("passwordRequestData: \(jsonResult)")
                    
                    let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                    
                    //print("dataDict: \(dataDict)")
                    
                    let uploadData : NSDictionary = dataDict.object(forKey: "passwordRequestData") as! NSDictionary
                    
                    let status = uploadData.object(forKey: "status") as? String
                    
                    DispatchQueue.main.sync(execute: {
                        
                        if status != nil && status == "Password request sent" {
                            
                            self.sendPasswordRequest()
                        }
                        else
                        {
                            DispatchQueue.main.sync(execute: {
                                
                                self.activityView.stopAnimating()
                                self.activityView.isHidden = true
                                
                                let alert = UIAlertController(title: "Password Request Error", message: status, preferredStyle: UIAlertControllerStyle.alert)
                                
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
                    })
                }
                catch let err as NSError
                {
                    print("error: \(err.description)")
                }
                
            }.resume()
        }
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
