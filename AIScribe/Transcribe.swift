//
//  Transcribe.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import MobileCoreServices
import Alamofire
import AVFoundation

class Transcribe: BaseViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var filenameLbl: UILabel!
    var languageList = NSMutableArray()
    var modelsList = NSMutableArray()
    
    @IBOutlet weak var filenameLblHeight: NSLayoutConstraint!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var sandboxURL  : URL?
    var selectedLanguage : NSDictionary?
    var selectedModel : NSDictionary?
    var selectedCode : String?
    var hasFile: Bool?
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!

    @IBOutlet weak var fileBtn: UIButton!
    @IBOutlet weak var languageBtn: UIButton!
    @IBOutlet weak var transcribeBtn: UIButton!
    @IBOutlet weak var languagePicker: UIPickerView!
    @IBOutlet weak var languagePopup: UIView!
    var cost : Float?
    
    @IBOutlet weak var modelsBtn: UIButton!
    
    @IBOutlet weak var modelsBtnHeight: NSLayoutConstraint!
    
    var showingLanguage : Bool?
    var cid : String?
    var selectedLang : String?
    var selectedModelName : String?
    
    @IBOutlet weak var customModelTopPadding: NSLayoutConstraint!
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let tb : TabController = self.parent as! TabController
        
        menuBtn.addTarget(self, action: #selector(tb.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)

        activityView.isHidden = true
        languagePicker.delegate = self
        languagePicker.dataSource = self
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        
        modelsBtn.isHidden = true
        modelsBtnHeight.constant = 0
        customModelTopPadding.constant = 0
        cid = ""
        
        getLanguages()
        
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideTranscribePickerNotification),
            name: NSNotification.Name(rawValue: "hideTranscribePicker"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(resetTranscriptionNotification),
            name: NSNotification.Name(rawValue: "resetTranscription"),
            object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(hideTranscriptionActivityViewNotification),
            name: NSNotification.Name(rawValue: "hideTranscriptionActivityView"),
            object: nil)
    }
    
    @objc func hideTranscriptionActivityViewNotification (notification: NSNotification) {
        
        print("hideTranscriptionActivityViewNotification")
        
        activityView.stopAnimating()
        activityView.isHidden = true
        
        resetFields()
    }
    
    @objc func resetTranscriptionNotification (notification: NSNotification) {
        
        resetFields()
    }
    
    func resetFields() {
        
        print("reset transcription defaults")
        
        activityView.stopAnimating()
        activityView.isHidden = true
        
        //file = nil
        languagePicker.selectRow(0, inComponent: 0, animated: false)
        filenameLbl.text = ""
        languagePopup.isHidden = true
        filenameLblHeight.constant = 0
        transcribeBtn.isEnabled = false
        modelsBtn.isEnabled = true
        languageBtn.isEnabled = true
        fileBtn.isEnabled = true
        languageBtn.setTitle("Choose audio language...", for: .normal)
        languageBtn.backgroundColor = UIColor.init(red: 214/255.0, green: 217/255.0, blue: 217/255.0, alpha: 1.0)
        transcribeBtn.backgroundColor = appDelegate.gray74
        transcribeBtn.setTitle("TRANSCRIBE", for: .normal)
        selectedCode = nil
        
        
        self.modelsBtn.isHidden = true
        self.modelsBtnHeight.constant = 0
        self.customModelTopPadding.constant = 0
        self.cid = nil
        self.selectedModel = nil
        self.modelsBtn.setTitle("Custom models...", for: .normal)
    }
    
    @objc func hideTranscribePickerNotification (notification: NSNotification) {
        
        print("hideTranscribePickerNotification")
        
        languagePopup.isHidden = true
    }
    
    @IBAction func showPopup(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        if btn.restorationIdentifier == "languageBtn"
        {
            showingLanguage = true
            
            if selectedLanguage == nil
            {
                selectedLanguage = languageList[0] as? NSDictionary
            }
            else
            {
                let ind = self.languageList.index(of: selectedLanguage!)
                languagePicker.selectRow(ind, inComponent: 0, animated: false)
            }
        }
        else
        {
            showingLanguage = false
            
            if selectedModel == nil
            {
                selectedModel = modelsList[0] as? NSDictionary
                languagePicker.selectRow(0, inComponent: 0, animated: false)
            }
            else
            {
                let ind = self.modelsList.index(of: selectedModel!)
                languagePicker.selectRow(ind, inComponent: 0, animated: false)
            }
        }
        
        languagePicker.reloadAllComponents()
        languagePopup.isHidden = false
    }
    
    @IBAction func transcribeFile(_ sender: Any) {
        
        print("transcribe file")
        
        activityView.startAnimating()
        activityView.isHidden = false
        transcribeBtn.isEnabled = false
        modelsBtn.isEnabled = false
        languageBtn.isEnabled = false
        fileBtn.isEnabled = false
        
        transcribeBtn.setTitle("TRANSCRIBING", for: .normal)
        
        initTransribeAF()
    }
    
    @IBAction func selectLanguage(_ sender: Any) {
        
        if showingLanguage == true
        {
            if selectedLanguage == nil
            {
                selectedLanguage = languageList[0] as? NSDictionary
            }
            
            selectedCode = selectedLanguage?.object(forKey: "code") as? String
            selectedLang = selectedLanguage?.object(forKey: "modelname") as? String
            languageBtn.setTitle(selectedLang, for: .normal)
            
            validateForm()
            getLanguageModels()
        }
        else
        {
            cid = selectedModel?.object(forKey: "cid") as? String
            selectedModelName = selectedModel?.object(forKey: "modelname") as? String
            modelsBtn.setTitle(selectedModelName, for: .normal)
            print("cid: \(cid!)")
        }
        
        languagePopup.isHidden = true
    }
    
    func validateForm() {
        
        if selectedLanguage != nil && hasFile == true
        {
            transcribeBtn.backgroundColor = appDelegate.crGreen
            transcribeBtn.isEnabled = true
        }
        else
        {
            transcribeBtn.backgroundColor = appDelegate.gray74
            transcribeBtn.isEnabled = false
        }
    }
    
    @IBAction func openFile(_ sender: Any) {
        
        let docPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeMP3 as String, kUTTypeWaveformAudio as String, kUTTypeAudio as String], in: .import)
        docPicker.delegate = self
        docPicker.allowsMultipleSelection = false
        present(docPicker, animated: true, completion: nil)
    }
    
    // MARK: Webservice
    
    func getLanguageModels() {
        
        modelsList.removeAllObjects()
        
        print("getLanguageModels")
        
        let dataString = "modelsData"
        
        let urlString = "\(appDelegate.serverDestination!)getLanguageModelsJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&code=\(selectedCode!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("models jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.modelsBtn.isHidden = true
                        self.modelsBtnHeight.constant = 0
                        self.customModelTopPadding.constant = 0
                        self.cid = nil
                        self.selectedModel = nil
                        self.modelsBtn.setTitle("Custom models...", for: .normal)
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
                            
                            self.modelsList.add(dict)
                        }
                        
                        self.selectedModel = self.modelsList[0] as? NSDictionary
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            if self.modelsList.count > 0
                            {
                                self.modelsBtn.isHidden = false
                                self.modelsBtnHeight.constant = 35
                                self.customModelTopPadding.constant = 8
                            }
                            else
                            {
                                self.modelsBtn.isHidden = true
                                self.modelsBtnHeight.constant = 0
                                self.customModelTopPadding.constant = 0
                            }
                            
                            //self.languagePicker.reloadAllComponents()
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
                    
                    //self.statusLbl.isHidden = false
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
                            self.selectedCode = self.selectedLanguage?.object(forKey: "code") as? String
                            
                            self.getLanguageModels()
                            
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
    
    func initTransribeAF () {
        
        let language = self.selectedLanguage?.object(forKey: "code") as! String
        
        if cid == nil
        {
            cid = ""
        }
        
        let params = [
            "uid": appDelegate.userid,
            "language": language,
            "estimatedCost": "\(self.cost!)",
            "cid": cid!,
            "mobile": "true"
        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.sandboxURL!, withName: "file")
                for (key, value) in params {
                    multipartFormData.append((value?.data(using: String.Encoding.utf8)!)!, withName: key)
                }
        },
            to: "http://localhost:8888/aiscribe/initTranscribeJSON.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        print("response: \(response)")
                        
                        if let JSON = response.result.value {
                            
                            //print("JSON: \(JSON)")
                            
                            let dataDict : NSDictionary = JSON as! NSDictionary
                            let data = dataDict.object(forKey: "data") as! NSDictionary
                            let transcribeData = data.object(forKey: "transcribeData") as! NSDictionary
                            
                            let status = transcribeData.object(forKey: "status") as! String
                            
                            if status == "document saved"
                            {
                                let did = transcribeData.object(forKey: "did") as! String
                                
                                let file = NSMutableDictionary()
                                file.setValue(did, forKey: "did")
                                file.setValue("Pending", forKey: "status")
                                file.setValue(self.sandboxURL!.lastPathComponent, forKey: "filename")
                                file.setValue("today", forKey: "date")
                                file.setValue(self.sandboxURL!, forKey: "url")
                                
                                NotificationCenter.default.post(name: Notification.Name("transcriptionStarted"), object: file)
                                
                                self.tabBarController?.selectedIndex = 0
                            }
                            else
                            {
                                self.activityView.isHidden = true
                                self.activityView.stopAnimating()
                                
                                self.transcribeBtn.isEnabled = true
                                self.transcribeBtn.backgroundColor = self.appDelegate.crGreen
                                self.transcribeBtn.setTitle("TRANSCRIBE", for: .normal)
                                
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
                        }
                    }
                case .failure(let encodingError):
                    print(encodingError)
                }
        }
        )
    }
    
    func sendDoc2 () {
        
//        var parameters: Parameters = [
//            "ingredients": "newIngredientOptions",
//            "userid": "",
//            "recipeid": "recipeID",
//            "servings": "servingSize"
//        ]
        
        Alamofire.upload(
            multipartFormData: { multipartFormData in
                multipartFormData.append(self.sandboxURL!, withName: "file")
                
        },
            to: "http://localhost:8888/aiscribe/getFileLengthAF.php",
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .success(let upload, _, _):
                    upload.responseJSON { response in
                        
                        print("response: \(response)")
                        
                        if let JSON = response.result.value {
                            
                            //print("JSON: \(JSON)")
                            
                            let dataDict : NSDictionary = JSON as! NSDictionary
                            
                            let len = dataDict.object(forKey: "len")
                            self.cost = dataDict.object(forKey: "estimatedCost") as? Float
                            
                            print("len: \(len!)")
                            
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
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension Transcribe : UIDocumentPickerDelegate
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
            
            if sandboxURL!.pathExtension == "mp3" || sandboxURL!.pathExtension == "wav" || sandboxURL!.pathExtension == "flac"
            {
                filenameLblHeight.constant = 50
                filenameLbl.text = sandboxURL!.lastPathComponent
                //sendDoc2()
                
//                let item = AVPlayerItem(url: sandboxURL!)
//
//                let player = AVPlayer(playerItem: item)
//                let duration = player.currentItem?.duration.seconds
                
                
                let asset = AVURLAsset(url: sandboxURL!, options: nil)
                let audioDuration = asset.duration
                let audioDurationSeconds = CMTimeGetSeconds(audioDuration)
                
                //print("duration: \(duration)")
                print("audioDurationSeconds: \(audioDurationSeconds)")
                
                let costPerSecond = 0.02/60;
                let markup = 0.5;
                let markupTotal = (costPerSecond * markup) + costPerSecond
                
                //console.log("costPerSecond: " + costPerSecond);
                //console.log("markupTotal: " + markupTotal);
                
                var estimatedCost = Double(Int(audioDurationSeconds)) * Double(markupTotal)
                
                //console.log("estimatedCost: " + estimatedCost.toFixed(2));
                
                if(estimatedCost < 1)
                {
                    estimatedCost = 1.0
                }
                
                
                    
                self.cost = Float(estimatedCost)
                
                let cd = String(format: "%.2f", self.cost!)
                
                self.hasFile = true
                self.filenameLblHeight.constant = 50
                self.filenameLbl.text = "\(self.sandboxURL!.lastPathComponent)\n Estimated Cost: $\(cd)"
                
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
        
        if showingLanguage == true
        {
            return languageList.count
        }
        else
        {
            return modelsList.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        if showingLanguage == true
        {
            selectedLanguage = languageList[row] as? NSDictionary
        }
        else
        {
            selectedModel = modelsList[row] as? NSDictionary
        }
        //currentPhaseInd = row
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        var lang : NSDictionary?
        
        if showingLanguage == true
        {
            lang = languageList[row] as? NSDictionary
            
        }
        else
        {
            lang = modelsList[row] as? NSDictionary
        }
        
        var model = lang!.object(forKey: "modelname") as? String
        model = model!.replacingOccurrences(of: "- Narrowband", with: "")
        
        return model
    }
}

