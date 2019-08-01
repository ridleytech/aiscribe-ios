//
//  Translate.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import AVFoundation

class Translate: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sandboxURL  : URL?
    var selectedLanguage : NSDictionary?
    var selectedCode : String?
    var hasFile: Bool?
    var languageList = NSMutableArray()
    var cost : Float?
    var file : NSDictionary?
    
    @IBOutlet weak var fileBtn: UIButton!
    @IBOutlet weak var filenameLbl: UILabel!
    @IBOutlet weak var filenameLblHeight: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var languageBtn: UIButton!
    @IBOutlet weak var transcribeBtn: UIButton!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var languagePopup: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        languageBtn.setTitle("Choose output language...", for: .normal)
        let tb : TabController = self.parent as! TabController
        
        menuBtn.addTarget(self, action: #selector(tb.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
        
        activityView.isHidden = true
        languagePicker.delegate = self
        languagePicker.dataSource = self
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        getLanguages()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideTranscribePickerNotification),
            name: NSNotification.Name(rawValue: "hideTranscribePicker"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetTranslationNotification),
            name: NSNotification.Name(rawValue: "resetTranslation"),
            object: nil)
    }
    
    @objc func resetTranslationNotification (notification: NSNotification) {
        
        print("reset translation defaults")
        
        file = nil
        languagePicker.selectRow(0, inComponent: 0, animated: false)
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        languageBtn.setTitle("Choose output language...", for: .normal)
        languageBtn.backgroundColor = UIColor.init(red: 214/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1.0)
        transcribeBtn.backgroundColor = appDelegate.gray74
        transcribeBtn.setTitle("TRANSLATE", for: .normal)
        selectedCode = nil
    }
    
    @objc func hideTranscribePickerNotification (notification: NSNotification) {
        
        print("hideTranscribePickerNotification")
        
        languagePopup.isHidden = true
    }
    
    @IBAction func showPopup(_ sender: Any) {
        
        if selectedLanguage == nil
        {
            selectedLanguage = languageList[0] as! NSDictionary
        }
        
        languagePopup.isHidden = false
    }
    
    @IBAction func translateFile(_ sender: Any) {
        
        print("translate file")
        
        activityView.startAnimating()
        activityView.isHidden = false
        transcribeBtn.isEnabled = false
        fileBtn.isEnabled = false
        languageBtn.isEnabled = false
        transcribeBtn.setTitle("TRANSLATING", for: .normal)
        
        initTranslate()
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        
        selectedCode = selectedLanguage?.object(forKey: "code") as? String
        let selectedLang = selectedLanguage?.object(forKey: "displayname") as? String
        languageBtn.setTitle(selectedLang, for: .normal)
        languagePopup.isHidden = true
        validateForm()
    }
    
    func validateForm() {
        
        if selectedLanguage != nil && hasFile == true
        {
            transcribeBtn.backgroundColor = appDelegate.crGreen
            transcribeBtn.isEnabled = true
        }
    }
    
    @IBAction func openFile(_ sender: Any) {
        
        let docPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String], in: .import)
        //let docPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String, kUTTypePDF as String], in: .import)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true, completion: nil)
    }
    
    // MARK: Webservice
    
    func getLanguages() {
        
        print("getLanguages")
        
        let dataString = "languageData"
        
        let urlString = "\(appDelegate.serverDestination!)getLanguages.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("languages jsonResult: \(jsonResult)")
                
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
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    if (uploadData.count > 0)
                    {
                        
                        //let list = uploadData as! NSMutableArray
                        
                        for ob in uploadData {
                            
                            let dict = ob as! NSDictionary
                            
                            self.languageList.add(dict)
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
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
    
    func initTranslate() {
        
        print("initTranslate")
        
        let dataString = "translateData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-translate.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let language = self.selectedLanguage?.object(forKey: "code") as! String
        
//        let params = [
//            "userid": appDelegate.userid,
//            "language": language,
//            "estimatedCost": self.cost!,
//            "displayLang": selectedLanguage?.object(forKey: "displayname") as? String,
//            "fileName": sandboxURL!.lastPathComponent,
//            "fileType": sandboxURL!.pathExtension,
//            "mobile": "true"
//        ]
        
        let displayLanguage = selectedLanguage?.object(forKey: "displayname") as? String
        
        let paramString = "uid=\(appDelegate.userid!)&fileName=\(sandboxURL!.lastPathComponent)&fileType=\(sandboxURL!.pathExtension)&displayLanguage=\(displayLanguage!)&language=\(language)&estimatedCost=\(self.cost!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("transcribeData jsonResult: \(jsonResult)")
                
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
                    let transcribeData = dataDict[dataString]! as! NSDictionary
                    
                    if (transcribeData != nil)
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            if transcribeData.object(forKey: "translationid") != nil
                            {
                                let translationid = transcribeData.object(forKey: "translationid") as! String
                                
                                let translation = transcribeData.object(forKey: "translation") as! String
                                let did = transcribeData.object(forKey: "did") as! String
                                
                                self.file = NSMutableDictionary()
                                self.file!.setValue(translation, forKey: "translation")
                                self.file!.setValue(translationid, forKey: "translationid")
                                self.file!.setValue(did, forKey: "did")
                                self.file!.setValue(self.selectedLanguage?.object(forKey: "displayname") as? String, forKey: "displayLanguage")
                                
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                self.fileBtn.isEnabled = true
                                self.languageBtn.isEnabled = true

                                NotificationCenter.default.post(name: Notification.Name("refreshFiles"), object: nil)
                                self.performSegue(withIdentifier: "EditTranslation", sender: nil)
                            }
                            else
                            {
                                let status = transcribeData.object(forKey: "status") as! String
                                
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                self.fileBtn.isEnabled = true
                                self.languageBtn.isEnabled = true
                                self.transcribeBtn.isEnabled = true
                                self.transcribeBtn.backgroundColor = self.appDelegate.crGreen
                                self.transcribeBtn.setTitle("TRANSLATE", for: .normal)
                                
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
    
    func initTranslateAF () {
        
        let language = self.selectedLanguage?.object(forKey: "code") as! String
        
        print("ext: \(sandboxURL!.pathExtension)")
        print("filename: \(sandboxURL!.lastPathComponent)")
        
        let params = [
            "userid": appDelegate.userid,
            "language": language,
            "estimatedCost": "\(self.cost!)",
            "displayLang": selectedLanguage?.object(forKey: "displayname") as? String,
            "fileName": sandboxURL!.lastPathComponent,
            "fileType": sandboxURL!.pathExtension,
            "mobile": "true"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.sandboxURL!, withName: "file")
                for (key, value) in params {
                    multipartFormData.append((value?.data(using: String.Encoding.utf8)!)!, withName: key)
                }
        },
            to: "http://localhost:8888/aiscribe/IBM-translate.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        print("response: \(response)")
                        
                        if let JSON = response.result.value {
                            
                            //print("JSON: \(JSON)")
                            
                            let dataDict : NSDictionary = JSON as! NSDictionary
                            let data = dataDict.object(forKey: "data") as! NSDictionary
                            let transcribeData = data.object(forKey: "translateData") as! NSDictionary
                            
                            
                            let translationid = transcribeData.object(forKey: "translationid") as! String
                            
                            if translationid != "none"
                            {
                                let translation = transcribeData.object(forKey: "translation") as! String
                                let did = transcribeData.object(forKey: "did") as! String
                                
                                self.file = NSMutableDictionary()
                                self.file!.setValue(translation, forKey: "translation")
                                self.file!.setValue(translationid, forKey: "translationid")
                                self.file!.setValue(did, forKey: "did")
                                self.file!.setValue(self.selectedLanguage?.object(forKey: "displayname") as? String, forKey: "displayLang")
                                
                                self.performSegue(withIdentifier: "EditTranslation", sender: nil)
                            }
                        }
                        
                        //debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
    func getWordCount () {
        
        let params = [
            "mobile": "true"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.sandboxURL!, withName: "file")
                for (key, value) in params {
                    multipartFormData.append((value.data(using: String.Encoding.utf8)!), withName: key)
                }
        },
            to: "http://localhost:8888/aiscribe/getWordCountAF.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        print("response: \(response)")
                        
                        if let JSON = response.result.value {
                            
                            //print("JSON: \(JSON)")
                            
                            let dataDict : NSDictionary = JSON as! NSDictionary
                            let data = dataDict.object(forKey: "data") as! NSDictionary
                            let wordData = data.object(forKey: "wordData") as! NSDictionary
                            
                            //let len = dataDict.object(forKey: "len")
                            
                            let costS = wordData.object(forKey: "total") as? Double
                            
                            self.cost = Float(costS!)
                            
                            //print("len: \(len!)")
                            
                            self.hasFile = true
                            self.filenameLblHeight.constant = 50
                            
                            let cd = String(format: "%.2f", self.cost!)
                            
                            self.filenameLbl.text = "\(self.sandboxURL!.lastPathComponent)\n Estimated Cost: $\(cd)"
                            
                            self.validateForm()
                        }
                        
                        //debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
        
        //https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#uploading-data-to-a-server
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditTranslation"
        {
            let destination = segue.destination as! TranslationResult
            destination.selectedFile = file
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension Translate : UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedURL = urls.first else {
            
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        sandboxURL = dir.appendingPathComponent(selectedURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxURL!.path)
        {
            print("do nothin")
            print("sandboxURL: \(sandboxURL!)")
            print("selectedURL: \(selectedURL)")
            print("ext: \(sandboxURL!.pathExtension)")
            print("filename: \(sandboxURL!.lastPathComponent)")
            
//            if sandboxURL!.pathExtension == "pdf" || sandboxURL!.pathExtension == "txt" || sandboxURL!.pathExtension == "doc"
//            {
                if sandboxURL!.pathExtension == "txt" || sandboxURL!.pathExtension == "doc"
                {
                filenameLblHeight.constant = 50
                //filenameLbl.text = sandboxURL!.lastPathComponent
                getWordCount()
                
                
//                self.hasFile = true
//                self.filenameLblHeight.constant = 50
//                self.filenameLbl.text = "\(self.sandboxURL!.lastPathComponent)\n Estimated Cost: \(self.cost!)"
//
//                self.validateForm()
            }
            else
            {
                let alert = UIAlertController(title: nil, message: "Invalid file type", preferredStyle: UIAlertControllerStyle.alert)
                
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
            }
        }
        else
        {
            do {
                
                try FileManager.default.copyItem(at: selectedURL, to: sandboxURL!)
                print("copied!")
            }
            catch
            {
                print("Error: \(error)")
            }
        }
    }
    
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
        let model = lang.object(forKey: "displayname") as? String
        
        return model
    }
}

