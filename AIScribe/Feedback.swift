//
//  Feedback.swift
//  AIScribe
//
//  Created by Randall Ridley on 3/9/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class Feedback: UIViewController, UITextViewDelegate {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var textTV: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
        
        textTV.delegate = self
        textTV.text = "Please give us your feedback"
        
        // Do any additional setup after loading the view.
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        textTV?.inputAccessoryView = keyboardDoneButtonView
        textTV?.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        //debug()
    }
    
    func sendFeedback() {
        
        self.view.endEditing(true)
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.crWarmGray
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("sendFeedback")
        
        let urlString = "\(appDelegate.serverDestination!)addFeedback.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "feedback=\(textTV.text!)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("add user jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["feedbackData"]! is NSNull
                {
                    print("no data")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                }
                else
                {
                    let userDict : NSDictionary = dataDict["feedbackData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "feedback saved")
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()

//                            self.submitBtn.isEnabled = true
//                            self.submitBtn.alpha = 1
                            
                            let alert = UIAlertController(title: nil, message: "Thank you for your feedback!", preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    
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
    
    func dismiss() {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
   
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
        
        if textTV.text != ""
        {
            submitBtn.isEnabled = true
            submitBtn.backgroundColor = appDelegate.crLightBlue
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Please give us your feedback"
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == ""
        {
            textView.text = "Please give us your feedback"
        }
    }
    
    @IBAction func submit() {
        
        if textTV.text != "" && textTV.text != "Please give us your feedback"
        {
            sendFeedback()
        }
        else
        {
            showBasicAlert(string: "Please enter feedback")
        }
    }
    
    @IBAction func cancel() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
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
}
