//
//  EditCorpus.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/27/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class EditCorpus: UIViewController, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    var selectedCorpus : CorpusItem?
    
    @IBOutlet weak var transcriptionTV: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var modelNameTxt: UITextField!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var modelNameLbl: UILabel!
    @IBOutlet weak var modelLblHeight: NSLayoutConstraint!
    @IBOutlet weak var statusTxt: UITextField!
    
    var status : String?
    
    @IBOutlet weak var infoIcon: UIButton!
    
    var statusTimer : Timer?
    var refreshCount : Int = 0
    var timerStarted : Bool?

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        infoIcon.isHidden = true
        activityView.isHidden = true
        modelNameTxt.isEnabled = false
        modelNameTxt.text = selectedCorpus?.filename
        
        transcriptionTV.text = selectedCorpus?.content
        transcriptionTV.delegate = self
        transcriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        transcriptionTV?.inputAccessoryView = keyboardDoneButtonView
        
        getCorpusInfo()
    }
    
    override func viewDidLayoutSubviews() {
        
        transcriptionTV?.scrollRangeToVisible(NSMakeRange(0, 0))
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        dismissKeyboard()
    }
    
    func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    // MARK: Webservice
    
    func getCorpusInfo() {
        
        print("getCorpusInfo")
        
        let dataString = "corpusData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-corpus-info.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&cid=\(selectedCorpus!.cid)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("corpus info jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.showBasicAlert(string: "Error retreiving corpus info.")
                        
                        //self.noResultsMain.isHidden = false
                    })
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        //self.status = uploadData.object(forKey: "status") as? String
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.status = uploadData.object(forKey: "status") as? String
                            self.infoIcon.isHidden = false
                            
                            if (self.status == "being_processed") {
                                
                                //start status refresh timer
                                
                                if self.timerStarted != true
                                {
                                    self.statusTimer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.refreshStatus), userInfo: nil, repeats: true)
                                    self.timerStarted = true
                                }
                            }
                            else
                            {
                                print("stop refresh timer")
                                
                                self.statusTimer?.invalidate()
                                self.timerStarted = false
                                
                                NotificationCenter.default.post(name: Notification.Name("refreshCorpora"), object: nil)
                            }
                            
                            var displayText = ""
                            
                            if self.status == "analyzed"
                            {
                                displayText = "Analyzed"
                            }
                            else if self.status == "being_processed"
                            {
                                displayText = "Being processed"
                            }
                            else
                            {
                                displayText = "Undetermined"
                            }
                            
                            self.infoIcon.isHidden = false
                            self.statusTxt.text = displayText
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            //self.noResultsMain.isHidden = false
                            
                            self.showBasicAlert(string: "Error retreiving corpus info.")
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
    
    @objc func refreshStatus () {
        
        refreshCount += 1
        
        if refreshCount <= 20
        {
            getCorpusInfo()
        }
        else
        {
            statusTimer?.invalidate()
            timerStarted = false
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
    
    func updateCorpus () {
        
        print("updateCorpus")
        
        let dataString = "corpusData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-create-corpus.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&filename=\(selectedCorpus!.filename)&cpid=\(selectedCorpus!.cpid)&cid=\(selectedCorpus!.cid)&content=\(transcriptionTV.text!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("corpus update jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                        //self.noResultsMain.isHidden = false
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        let status = uploadData.object(forKey: "status") as! String
                        
                        print("status: \(status)")
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if status == "corpus updated successfully"
                            {
                                //self.refreshFiles()
                                
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                NotificationCenter.default.post(name: Notification.Name("refreshCorpora"), object: nil)
                                
                                let alert = UIAlertController(title: "Corpus Updated Sucessfully", message: "Custom model \(self.selectedCorpus!.modelname) needs to be retrained after new corpus data is analyzed.", preferredStyle: UIAlertControllerStyle.alert)
                                
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
                            }
                            else
                            {
                                self.saveBtn.isEnabled = true
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                let alert = UIAlertController(title: "Upload Error", message: status, preferredStyle: UIAlertControllerStyle.alert)
                                
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
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            //self.noResultsMain.isHidden = false
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
    
    func updateCorpus1 () {
        
        print("updateCorpus")
        
        let dataString = "corpusData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-update-corpus.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&filename=\(selectedCorpus!.filename)&cpid=\(selectedCorpus!.cpid)&content=\(transcriptionTV.text!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("corpus update jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                        //self.noResultsMain.isHidden = false
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        let status = uploadData.object(forKey: "status") as! String
                        
                        print("status: \(status)")
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if status == "corpus update successful"
                            {
                                //self.refreshFiles()
                                
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                NotificationCenter.default.post(name: Notification.Name("refreshCorpora"), object: nil)
                                
                                let alert = UIAlertController(title: nil, message: "Corpus Updated Sucessfully", preferredStyle: UIAlertControllerStyle.alert)
                                
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
                            }
                            else
                            {
                                self.saveBtn.isEnabled = true
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                let alert = UIAlertController(title: "Upload Error", message: status, preferredStyle: UIAlertControllerStyle.alert)
                                
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
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            //self.noResultsMain.isHidden = false
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
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        validateForm()
    }
    
    func validateForm() {
        
        if transcriptionTV.text != ""
        {
            saveBtn.backgroundColor = appDelegate.crLightBlue
            saveBtn.isEnabled = true
        }
        else
        {
            saveBtn.backgroundColor = appDelegate.gray74
            saveBtn.isEnabled = false
        }
    }
    
    @IBAction func showStatusInfo(_ sender: Any) {
        
        if (status == "being_processed") {
            status = "Being Processed indicates that the service is still analyzing the corpus. The service cannot accept requests to add new corpora or words, or to train the custom model, until its analysis is complete."
        } else if (status == "undetermined") {
            status = "Undetermined indicates that the service encountered an error while processing the corpus. The information that is returned for the corpus includes an error message that offers guidance for correcting the error."
        } else {
            status = "Analyzed indicates that the service successfully analyzed the corpus. The custom model can be trained with data from the corpus."
        }
        
        let alert = UIAlertController(title: nil, message: status, preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    @IBAction func updateFile(_ sender: Any) {
        
        saveBtn.backgroundColor = appDelegate.gray74
        saveBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
     
        updateCorpus()
    }

    @IBAction func cancel(_ sender: Any) {
        
        dismissKeyboard()
        dismiss()
    }
    
    func dismiss() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
}

extension String {
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    mutating func capitalizeFirstLetter() {
        self = self.capitalizingFirstLetter()
    }
}
