//
//  TranslationResult.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import Alamofire

class TranslationResult: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var filenameLbl: UILabel!
    @IBOutlet weak var transcriptionTV: UITextView!
    @IBOutlet weak var outputLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!

    var did : String?
    var filename: String?
    var lang: String?
    var translationid: String?
    var selectedFile: NSDictionary?
    var textChanged:Bool?
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    var currentValue: String?
    
    @IBOutlet weak var previewView: UIView!
    var webView: UIWebView?
    
    var displayLanguage : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        previewView.isHidden = true
        
        if selectedFile?.object(forKey: "translation") as? String != nil
        {
            activityView.isHidden = true
            activityView.stopAnimating()
            
            let res = selectedFile!.object(forKey: "translation") as! String
            
            self.transcriptionTV.text = res
            self.filenameLbl.text = self.filename
            self.outputLbl.text = "Output Language: \(displayLanguage!)"
            
            NotificationCenter.default.post(name: Notification.Name("resetTranslation"), object: nil)
            
            cancelBtn.isHidden = true
            saveBtn.setTitle("Done", for: .normal)
        }
        else
        {
            activityView.startAnimating()
            getData()
        }
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        transcriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        transcriptionTV?.inputAccessoryView = keyboardDoneButtonView
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        currentValue = textField.text
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        if textField.text != currentValue
        {
            print("text changed")
            textChanged = true
            currentValue = textField.text
        }
    }
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func updateTranscription(_ sender: Any) {
        
        if textChanged == true
        {
            updateTranslation()
        }
        else
        {
            dismiss()
        }
    }
    
    func getData() {
        
        print("getData")
        
        let dataString = "translationData"
        
        let urlString = "\(appDelegate.serverDestination!)getTranslationJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        translationid = selectedFile?.object(forKey: "translationid") as? String
        lang = selectedFile?.object(forKey: "language") as? String
        
        let paramString = "did=\(did!)&lang=\(lang!)&translationid=\(translationid!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("translation jsonResult: \(jsonResult)")
                
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
                    
                    var res = uploadData.object(forKey: "translation") as! String
                    self.displayLanguage = uploadData.object(forKey: "displayLanguage") as? String
                    
                    res = res.replacingOccurrences(of: "\\'", with: "'")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        self.transcriptionTV.text = res
                        self.filenameLbl.text = self.filename
                        self.outputLbl.text = "Output Language: \(self.displayLanguage!)"
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
        }.resume()
    }
    
    func updateTranslation() {
        
        print("getData")
        
        let dataString = "translationData"
        
        let urlString = "\(appDelegate.serverDestination!)update-translation.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        translationid = selectedFile?.object(forKey: "translationid") as? String
        
        let paramString = "translation=\(transcriptionTV.text!)&translationid=\(translationid!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("translation jsonResult: \(jsonResult)")
                
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
                        
                        if status == "Translation updated successfully"
                        {
                            let alert = UIAlertController(title: nil, message: status, preferredStyle: UIAlertControllerStyle.alert)
                            
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
                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
            }.resume()
    }
    
    func createDoc() {
        
        print("createDoc")
        
        let dataString = "docData"
        
        let urlString = "\(appDelegate.serverDestination!)phpword/createDocJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let str = filename?.split(separator: ".")
        
        let paramString = "filename=\(str![0])&lang=\(displayLanguage!)&input=\(transcriptionTV.text!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("docx jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                    })
                    
                    //self.statusLbl.isHidden = false
                }
                else
                {
                    let uploadData  = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        //let list = uploadData as! NSMutableArray
                        
                        let status = uploadData.object(forKey: "status") as! String
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            if status == "docx created successfully"
                            {
                                //download file
                                
                                let utilityQueue = DispatchQueue.global(qos: .utility)
                                
                                Alamofire.download("\(self.appDelegate.serverDestination!)\(self.filename!).docx")
                                    .downloadProgress(queue: utilityQueue) { progress in
                                        print("Download Progress: \(progress.fractionCompleted)")
                                        
                                        if(progress.fractionCompleted == 1.0)
                                        {
                                            print("done")
                                            
                                            DispatchQueue.main.sync(execute: {
                                                
                                                let appName = "ms-word"
                                                let appScheme = "/(appName)://app"
                                                //let appUrl = URL(string: appScheme)
                                                
                                                let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                                                
                                                //let url : NSString = "ms-word:ofv|u|https://www.dropbox.com/s/xxxxxx/new.docx?dl=0|p|xxxxxx|z|yes|a|App" as NSString
                                                
                                                let url : NSString = "\(appName):ofe|u|\(documentsPath)/\(self.filename!).docx|z|yes|a|App" as NSString
                                                let urlStr : NSString = url.addingPercentEscapes(using: String.Encoding.utf8.rawValue)! as NSString
                                                let searchURL : NSURL = NSURL(string: urlStr as String)!
                                                //UIApplication.shared.openURL(searchURL as URL)
                                                
                                                
                                                //if UIApplication.shared.canOpenURL(appUrl! as URL)
                                                if UIApplication.shared.canOpenURL(searchURL as URL)
                                                {
                                                    print("App installed")
                                                    UIApplication.shared.open(searchURL as URL)
                                                    
                                                } else {
                                                    print("App not installed")
                                                    
                                                    let alert = UIAlertController(title: nil, message: "You currently don't have an app installed to open Word files.", preferredStyle: UIAlertControllerStyle.alert)
                                                    
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
                                    }
                                    .responseData { response in
                                        
                                        if let data = response.result.value {
                                            
                                            print("data: \(data)")
                                        }
                                }
                            }
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
        
        //https://stackoverflow.com/questions/46251025/how-to-edit-and-save-microsoft-word-document-in-ios-stored-in-local-directory
        //https://docs.microsoft.com/en-us/office/client-developer/office-uri-schemes
        //
    }
    
    // MARK: File management
    
    func createPDF() {
        
        let html = "<b>\(self.filename!)</i></b><p>\(displayLanguage!)</p> <p>\(transcriptionTV.text!)</p>"
        let fmt = UIMarkupTextPrintFormatter(markupText: html)
        
        // 2. Assign print formatter to UIPrintPageRenderer
        
        let render = UIPrintPageRenderer()
        render.addPrintFormatter(fmt, startingAtPageAt: 0)
        
        // 3. Assign paperRect and printableRect
        
        let page = CGRect(x: 0, y: 0, width: 595.2, height: 841.8) // A4, 72 dpi
        let printable = page.insetBy(dx: 0, dy: 0)
        
        render.setValue(NSValue(cgRect: page), forKey: "paperRect")
        render.setValue(NSValue(cgRect: printable), forKey: "printableRect")
        
        // 4. Create PDF context and draw
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, .zero, nil)
        
        for i in 1...render.numberOfPages {
            UIGraphicsBeginPDFPage();
            let bounds = UIGraphicsGetPDFContextBounds()
            render.drawPage(at: i - 1, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        
        // 5. Save PDF file
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        pdfData.write(toFile: "\(documentsPath)/\(filename!).pdf", atomically: true)
        
        loadPDF(filename: filename!)
    }
    
    func loadPDF(filename: String) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent(filename).appendingPathExtension("pdf")
        let urlRequest = URLRequest(url: url)
        
        webView = UIWebView(frame: CGRect.init(x: 0, y: 55, width: view.frame.width, height: view.frame.height-55))
        
        webView!.delegate = self
        previewView.addSubview(webView!)
        previewView.isHidden = false
        webView!.loadRequest(urlRequest)
        
        let alert = UIAlertController(title: nil, message: "PDF successfully saved to your files.", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    func createTxt() {
        
        var filePath = ""
        
        // Fine documents directory on device
        let dirs : [String] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true)
        
        if dirs.count > 0 {
            let dir = dirs[0] //documents directory
            filePath = dir.appending("/" + filename! + ".txt")
            print("Local path = \(filePath)")
        } else {
            print("Could not find local directory to store file")
            return
        }
        
        // Set the contents
        let fileContentToWrite = "\(displayLanguage!)\n\n\(transcriptionTV.text!)"
        
        do {
            // Write contents to file
            try fileContentToWrite.write(toFile: filePath, atomically: false, encoding: String.Encoding.utf8)
            
            print("file saved")
            
            loadTXT(filename: filename!)
            
            let alert = UIAlertController(title: nil, message: "Text file successfully saved to your files.", preferredStyle: UIAlertControllerStyle.alert)
            
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
        catch let error as NSError {
            print("An error took place: \(error)")
        }
        
        //http://swiftdeveloperblog.com/code-examples/read-and-write-string-into-a-text-file/
    }
    
    func loadTXT(filename: String) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent(filename).appendingPathExtension("pdf")
        let urlRequest = URLRequest(url: url)
        
        webView = UIWebView(frame: CGRect.init(x: 0, y: 55, width: view.frame.width, height: view.frame.height-55))
        
        webView!.delegate = self
        previewView.addSubview(webView!)
        previewView.isHidden = false
        webView!.loadRequest(urlRequest)
    }
    
    func loadWordFile(file:String) {
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let url = URL(fileURLWithPath: documentsPath, isDirectory: true).appendingPathComponent(file).appendingPathExtension("docx")
        let urlRequest = URLRequest(url: url)
        
        webView = UIWebView(frame: CGRect.init(x: 0, y: 55, width: view.frame.width, height: view.frame.height-55))
        
        webView!.delegate = self
        previewView.addSubview(webView!)
        previewView.isHidden = false
        webView!.loadRequest(urlRequest)
        
        let alert = UIAlertController(title: nil, message: "Word doc successfully saved to your files.", preferredStyle: UIAlertControllerStyle.alert)
        
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
    
    // MARK: Webview Delegate
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
        print("webview start load")
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        print("webview finish load")
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        print("webview fail")
    }
    
    // MARK: Actions
    
    @IBAction func closePreview(_ sender: Any) {
        
        previewView.isHidden = true
    }
    
    @IBAction func createPDF(_ sender: Any) {
        
        createPDF()
    }
    
    @IBAction func createTXT(_ sender: Any) {
        
        createTxt()
    }
    
    @IBAction func createDOC(_ sender: Any) {
        
        createDoc()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        dismiss()
    }
    
    func dismiss() {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TranslationOptions"
        {
            let destination = segue.destination as! TranslationOptions
            destination.did = did
            destination.filename = filename
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
