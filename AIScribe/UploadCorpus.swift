//
//  UploadCorpus.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/27/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import AVFoundation

class UploadCorpus: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sandboxURL  : URL?
    var selectedModel : ModelItem?
    var cid : String?
    var hasFile: Bool?
    var languageList = NSMutableArray()
    var cost : String?
    var file : NSDictionary?
    
    @IBOutlet weak var filenameLbl: UILabel!
    @IBOutlet weak var filenameLblHeight: NSLayoutConstraint!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var languageBtn: UIButton!
    @IBOutlet weak var transcribeBtn: UIButton!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var languagePopup: UIView!
    
    var itemArray = [ModelItem]()
    var currentItemArray = [ModelItem]()
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
        languagePicker.delegate = self
        languagePicker.dataSource = self
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        getModels()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideCorpusPickerNotification),
            name: NSNotification.Name(rawValue: "hideCorpusPicker"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetCorpusNotification),
            name: NSNotification.Name(rawValue: "resetCorpus"),
            object: nil)
    }
    
    // MARK: Notifications
    
    @objc func resetCorpusNotification (notification: NSNotification) {
        
        print("reset corpus defaults")
        
        file = nil
        languagePicker.selectRow(0, inComponent: 0, animated: false)
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        languageBtn.setTitle("Choose model...", for: .normal)
        languageBtn.backgroundColor = UIColor.init(red: 214/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1.0)
        transcribeBtn.backgroundColor = appDelegate.gray74
        transcribeBtn.setTitle("UPLOAD", for: .normal)
        cid = nil
    }
    
    @objc func hideCorpusPickerNotification (notification: NSNotification) {
        
        print("hideCorpusPickerNotification")
        
        languagePopup.isHidden = true
    }
    
    // MARK: Actions
    
    @IBAction func showPopup(_ sender: Any) {
        
        if selectedModel == nil
        {
            selectedModel = currentItemArray[0]
        }
        
        languagePopup.isHidden = false
    }
    
    @IBAction func uploadFile(_ sender: Any) {
        
        print("upload file")
        
        activityView.startAnimating()
        activityView.isHidden = false
        transcribeBtn.isEnabled = false
        
        transcribeBtn.setTitle("UPLOADING", for: .normal)
        
        initUpload()
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        
        cid = selectedModel?.cid
        languageBtn.setTitle(selectedModel?.modelname, for: .normal)
        languagePopup.isHidden = true
        validateForm()
    }
    
    func validateForm() {
        
        if selectedModel != nil && hasFile == true
        {
            transcribeBtn.backgroundColor = appDelegate.crGreen
            transcribeBtn.isEnabled = true
        }
    }
    
    @IBAction func openFile(_ sender: Any) {
        
        let docPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeText as String], in: .import)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss()
    }
    
    func dismiss() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Webservice
    
    func getModels() {
        
        print("getModels")
        
        let dataString = "modelsData"
        
        let urlString = "\(appDelegate.serverDestination!)getModelsJSON.php"
        
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
                        
//                        self.statusView.isHidden = false
//                        self.refreshControl.endRefreshing()
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
                            
                            self.itemArray.append(ModelItem(modelname: dict.object(forKey: "modelname") as! String, modeldescription: dict.object(forKey: "modeldescription") as! String, basename1: dict.object(forKey: "basename1") as! String, mid: dict.object(forKey: "mid") as! String, cid: dict.object(forKey: "cid") as! String, status:  dict.object(forKey: "status") as! String))
                        }
                        
                        self.currentItemArray = self.itemArray
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.languagePicker.reloadAllComponents()
                            
//                            self.activityView.isHidden = true
//                            self.statusView.isHidden = true
//                            self.activityView.stopAnimating()
//                            self.modelsTable.reloadData()
//                            self.refreshControl.endRefreshing()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
//                            self.statusView.isHidden = false
//                            self.refreshControl.endRefreshing()
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
    
    func initUpload () {
        
        print("ext: \(sandboxURL!.pathExtension)")
        print("filename: \(sandboxURL!.lastPathComponent)")
        
        let params = [
            "userid": appDelegate.userid,
            "cid": cid!,
            "filename": sandboxURL!.lastPathComponent,
            "mobile": "true"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.sandboxURL!, withName: "file")
                for (key, value) in params {
                    multipartFormData.append((value?.data(using: String.Encoding.utf8)!)!, withName: key)
                }
        },
            to: "http://localhost:8888/aiscribe/IBM-create-corpus.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        print("response: \(response)")
                        
                        if let JSON = response.result.value {
                            
                            //print("JSON: \(JSON)")
                            
                            let dataDict : NSDictionary = JSON as! NSDictionary
                            let data = dataDict.object(forKey: "data") as! NSDictionary
                            let corpusData = data.object(forKey: "corpusData") as! NSDictionary
                            
                            let status = corpusData.object(forKey: "status") as! String
                            
                            if status == "corpus created successfully"
                            {
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                NotificationCenter.default.post(name: Notification.Name("refreshCorpora"), object: nil)

                                let alert = UIAlertController(title: nil, message: "Corpus Uploaded Sucessfully", preferredStyle: UIAlertControllerStyle.alert)
                                
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
                                //handle error
                                
                                self.transcribeBtn.isEnabled = true
                                
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
                        }
                        
                        //debugPrint(response)
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        })
    }
}

extension UploadCorpus : UIDocumentPickerDelegate
{
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        
        guard let selectedURL = urls.first else {
            
            return
        }
        
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        sandboxURL = dir.appendingPathComponent(selectedURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxURL!.path)
        {
            //print("do nothin")
            print("sandboxURL: \(sandboxURL!)")
            print("selectedURL: \(selectedURL)")
            print("ext: \(sandboxURL!.pathExtension)")
            print("filename: \(sandboxURL!.lastPathComponent)")
            
            if sandboxURL!.pathExtension == "txt"
            {
                filenameLblHeight.constant = 21
                filenameLbl.text = sandboxURL!.lastPathComponent
                
                self.hasFile = true
                self.validateForm()
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
        
        return currentItemArray.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        selectedModel = currentItemArray[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        let lang = currentItemArray[row]
        let model = lang.modelname
        
        return model
    }
}

