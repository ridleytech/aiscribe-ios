//
//  EditCustomModel.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/3/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class EditCustomModel: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITextViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    var selectedModel: ModelItem?
    var languageList = NSMutableArray()
    var selectedLanguage : NSDictionary?
    var selectedCode : String?

    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var modelNameTxt: UITextField!
    @IBOutlet weak var languageTxt: UITextField!
    @IBOutlet weak var transcriptionTV: UITextView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var showPopupBtn: UIButton!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var languagePopup: UIView!
    @IBOutlet weak var modelNameLbl: UILabel!
    @IBOutlet weak var modelLblHeight: NSLayoutConstraint!
    @IBOutlet weak var languageLbl: UILabel!
    @IBOutlet weak var languageLblHeight: NSLayoutConstraint!
    @IBOutlet weak var descriptionTxt: UITextField!
    @IBOutlet weak var statusTxt: UITextField!
    @IBOutlet weak var corpusTxt: UITextField!
    @IBOutlet weak var transcriptionsTxt: UITextField!
    @IBOutlet weak var trainBtn: UIButton!
    
    var status : String?
    
    @IBOutlet weak var infoIcon: UIButton!
    
    var statusTimer : Timer?
    var refreshCount : Int = 0
    var timerStarted : Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.activityView.isHidden = true
        saveBtn.isHidden = true
        trainBtn.isHidden = true
        infoIcon.isHidden = true
        
        modelNameTxt.delegate = self
        languageTxt.delegate = self
        //transcriptionTV.delegate = self
        
        modelNameTxt.restorationIdentifier = "modelname"
        
//        languagePicker.delegate = self
//        languagePicker.delegate = self
//        languagePopup.isHidden = true
//        saveBtn.isEnabled = false
//        saveBtn.backgroundColor = appDelegate.gray74
        
        if (selectedModel != nil)
        {
            modelNameTxt.text = selectedModel?.modelname
            languageTxt.text = selectedModel?.basename1
            //transcriptionTV.text = selectedModel?.modeldescription
            descriptionTxt.text = selectedModel?.modeldescription
            
            modelNameTxt.isEnabled = false
            languageTxt.isEnabled = false
            //showPopupBtn.isHidden = true
        }
        else
        {
            headerLbl.text = "Create Custom Model"
            //transcriptionTV.text = "Model Description"
            
            modelNameLbl.isHidden = true
            languageLbl.isHidden = true
            
            languageLblHeight.constant = 0
            modelLblHeight.constant = 0
        }
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]

//        transcriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
//        transcriptionTV?.inputAccessoryView = keyboardDoneButtonView
        modelNameTxt?.inputAccessoryView = keyboardDoneButtonView
        
        //getLanguages()
        validate()
        getModelInfo()
    }
    
    func validate() {
        
        if modelNameTxt.text != "" && languageTxt.text != ""
        {
            saveBtn.isEnabled = true
            saveBtn.backgroundColor = appDelegate.crLightBlue
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField.restorationIdentifier == "modelname"
        {
            modelNameLbl.isHidden = false
            modelLblHeight.constant = 18
            
            validate()
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if textView.text == "Model Description"
        {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if textView.text == ""
        {
            textView.text = "Model Description"
        }
    }
    
    @IBAction func showPopup(_ sender: Any) {
        
        dismissKeyboard()
        
        languagePopup.isHidden = false
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        
        selectedCode = selectedLanguage?.object(forKey: "code") as? String
        let selectedLang = selectedLanguage?.object(forKey: "modelname") as? String
        languageTxt.text = selectedLang!.replacingOccurrences(of: "- Narrowband", with: "")
        languagePopup.isHidden = true
        
        languageLbl.isHidden = false
        languageLblHeight.constant = 18
        
        validate()
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        dismissKeyboard()
    }
    
    func dismissKeyboard() {
        
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismissKeyboard()
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func trainModel(_ sender: Any) {
        
        print("train model")
        
        trainBtn.isEnabled = false
        
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        
        trainModel()
    }
    
    @IBAction func updateModel(_ sender: Any) {
        
        saveBtn.isEnabled = false
        
        self.activityView.isHidden = false
        self.activityView.startAnimating()
        
        if (selectedModel != nil)
        {
            updateModel()
        }
        else
        {
            createModel()
        }
    }
    
    @IBAction func showStatusInfo(_ sender: Any) {
        
        if (status == "pending") {
            status = "Pending indicates that the model was created. It is waiting for valid training data from a corpora to be added to finish analyzing data."
        } else if (status == "ready - train") {
            status = "Ready indicates that the model contains valid data and is ready to be trained."
        } else if (status == "failed") {
            status = "Failed indicates that training of the model failed. Examine the words in the model's words resource to determine the errors that prevented the model from being trained."
        } else if (status == "available") {
            status = "Available indicates that the model is trained and ready to use with a recognition request."
        } else if (status == "training") {
            status = "Training indicates that the model is being trained on data."
        } else if (status == "upgrading") {
            status = "Upgrading indicates that the model is being upgraded."
        } else if (status == "pending1") {
            status = "The model is currently analyzing new corpus data."
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
    
    func getLanguages() {
        
        print("getLanguages")
        
        let dataString = "languageData"
        
        let urlString = "\(appDelegate.serverDestination!)getLanguagesJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        //print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("files jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.noResultsMain.isHidden = false
                    })
                }
                else
                {
                    let uploadData = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if (uploadData.count > 0)
                    {
                        //let list = uploadData as! NSMutableArray
                        
                        for ob in uploadData {
                            
                            let dict = ob as! NSDictionary
                            
                            self.languageList.add(dict)
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.selectedLanguage = self.languageList[0] as? NSDictionary
                            self.languagePicker.reloadAllComponents()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
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
    
    func getModelInfo() {
        
        print("getModelInfo")
        
        let dataString = "modelData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-model-info.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&cid=\(selectedModel!.cid)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("model info jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.showBasicAlert(string: "Error retreiving model info.")
                        
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
                            
                            if self.status == "ready"
                            {
                                self.trainBtn.isHidden = false
                                self.status = "\(self.status!) - train"
                            }
                            
                            if (self.status != "available" && self.status != "ready" && self.status != "ready - train" && self.status != "failed") {
                             
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
                            }                            
                            
                            self.infoIcon.isHidden = false
                            self.statusTxt.text = self.status
                            self.corpusTxt.text = uploadData.object(forKey: "corpusfile") as? String
                            self.transcriptionsTxt.text = uploadData.object(forKey: "transcriptions") as? String
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            //self.noResultsMain.isHidden = false
                            
                            self.showBasicAlert(string: "Error retreiving model info.")
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
    
    @objc func refreshStatus () {
        
        refreshCount += 1
        
        if refreshCount <= 20
        {
            getModelInfo()
        }
        else
        {
            statusTimer?.invalidate()
            timerStarted = false
        }
    }
    
    func createModel() {
        
        print("createModel")
        
        let dataString = "modelData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-create-model.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var modelDescription = ""
        
        if transcriptionTV.text != ""
        {
            modelDescription = transcriptionTV.text
        }
        
        let paramString = "modeldescription=\(modelDescription)&modelname=\(modelNameTxt.text!)&modelLanguage=\(selectedCode!)&uid=\(appDelegate.userid!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("create model jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.noResultsMain.isHidden = false
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString] as! NSDictionary
                    let status = uploadData.object(forKey: "status") as! String
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                        if status == "model created successfully"
                        {
                            NotificationCenter.default.post(name: Notification.Name("refreshCustomModels"), object: nil)
                            
                            let alert = UIAlertController(title: nil, message: "Model Created Successfully", preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                }
                            }))
                        }
                        
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
        }.resume()
    }
    
    func updateModel() {
        
        print("updateModel")
        
        let dataString = "modelData"

        let urlString = "\(appDelegate.serverDestination!)editModelJSON.php"

        let url = URL(string: urlString)

        var request = URLRequest(url: url!)

        request.httpMethod = "POST"
        
        let mid = selectedModel?.mid

        let paramString = "modeldescription=\(transcriptionTV.text!)&mid=\(mid!)&mobile=true&devStatus=\(appDelegate.devStage!)"

        print("urlString: \(urlString)")
        print("paramString: \(paramString)")

        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))

        let session = URLSession.shared

        session.dataTask(with: request) {data, response, err in

            do {

                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary

                print("model jsonResult: \(jsonResult)")

                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary

                if dataDict[dataString]! is NSNull {

                    print("no data")

                    DispatchQueue.main.sync(execute: {

                        //self.noResultsMain.isHidden = false
                    })

                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString] as! NSDictionary
                    let status = uploadData.object(forKey: "status") as! String
                    
                    DispatchQueue.main.sync(execute: {

                        if status == "model update successful"
                        {
                            NotificationCenter.default.post(name: Notification.Name("refreshCustomModels"), object: nil)
                            
                            let alert = UIAlertController(title: nil, message: "Model Saved", preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                    self.navigationController?.popViewController(animated: true)
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                }
                            }))
                        }
                        
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }

        }.resume()
    }
    
    func trainModel() {
        
        print("trainModel")
        
        let dataString = "trainData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-train-model.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "cid=\(selectedModel!.cid)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("model jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.noResultsMain.isHidden = false
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData = dataDict[dataString] as! NSDictionary
                    let status = uploadData.object(forKey: "status") as! String
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        
                        if status == "Model training started successfully"
                        {
                            NotificationCenter.default.post(name: Notification.Name("refreshCustomModels"), object: nil)
                            
                            let alert = UIAlertController(title: nil, message: status, preferredStyle: UIAlertControllerStyle.alert)
                            
                            self.present(alert, animated: true, completion: nil)
                            
                            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                switch action.style{
                                case .default:
                                    print("default")
                                    
                                    self.refreshStatus()
                                    
                                    //self.navigationController?.popViewController(animated: true)
                                    
                                case .cancel:
                                    print("cancel")
                                    
                                case .destructive:
                                    print("destructive")
                                }
                            }))
                        }
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
        }.resume()
    }
}

extension EditCustomModel : UIDocumentPickerDelegate
{
    // MARK: Pickerview
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return languageList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedLanguage = languageList[row] as? NSDictionary
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let lang = languageList[row] as! NSDictionary
        var model = lang.object(forKey: "modelname") as? String
        model = model!.replacingOccurrences(of: "- Narrowband", with: "")
        
        return model
    }
}

