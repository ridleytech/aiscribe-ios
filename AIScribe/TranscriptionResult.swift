//
//  TranscriptionResult.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit
import Alamofire

class TranscriptionResult: UIViewController, UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var did : String?

    @IBOutlet weak var confidenceLbl: UILabel!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var filenameLbl: UILabel!
    @IBOutlet weak var transcriptionTV: UITextView!
    var filename: String?
    @IBOutlet weak var saveBtn: UIButton!
    
    
    @IBOutlet weak var translationsView: UIView!
    var translationsList = NSMutableArray()
    var selectedFile: NSDictionary?
    
    @IBOutlet weak var translationTable: UITableView!
    
    @IBOutlet weak var previewView: UIView!
    var webView: UIWebView?
    var content : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.confidenceLbl.text = ""
        
        activityView.startAnimating()
        translationsView.isHidden = true
        // Do any additional setup after loading the view.
        translationTable.tableFooterView = UIView()
        translationTable.dataSource = self
        translationTable.delegate = self
        previewView.isHidden = true
        
        transcriptionTV.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)

        
        filenameLbl.text = filename
        
        getTranscriptionData()
        getTranslations()
        
        let keyboardDoneButtonView = UIToolbar()
        keyboardDoneButtonView.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .bordered, target: self, action: #selector(self.doneClicked))
        keyboardDoneButtonView.items = [doneButton]
        
        transcriptionTV?.inputAccessoryView = keyboardDoneButtonView
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTranslationsNotification1),
            name: NSNotification.Name(rawValue: "refreshTranslations1"),
            object: nil)
    }
    
    // MARK: Notifications
    
    @objc func refreshTranslationsNotification1 (notification: NSNotification) {
        
        print("handle")
        
        translationsList.removeAllObjects()
        
        getTranslations()
    }
    
    // MARK: Webservice
    
    func getTranslations() {
        
        print("getTranslations")
        
        let dataString = "translationData"
        
        let urlString = "\(appDelegate.serverDestination!)documentTranslationsJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "did=\(did!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("translations jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.translationsView.isHidden = false
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
                            
                            self.translationsList.add(dict)
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            self.translationTable.reloadData()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.translationsView.isHidden = false
                            
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
    
    func getTranscriptionData() {
        
        print("getTranscriptionData")
        
        let dataString = "transcriptionData"
        
        let urlString = "\(appDelegate.serverDestination!)transcriptionDataJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "did=\(did!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("transcription jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.noResultsMain.isHidden = false
                    })
                }
                else
                {
                    let uploadData = dataDict[dataString] as! NSDictionary
                    self.content = uploadData.object(forKey: "response") as! String
                    self.filename = uploadData.object(forKey: "filename") as? String
                    let documentconfidence = uploadData.object(forKey: "documentconfidence") as? String

                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        self.transcriptionTV.text = self.content
                        self.filenameLbl.text = self.filename
                        
                        if documentconfidence != ""
                        {
                            self.confidenceLbl.text = "Transcription Confidence: \(documentconfidence!)%"
                        }
                        else
                        {
                            self.confidenceLbl.text = ""
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
        
        let urlString = "\(appDelegate.serverDestination!)/phpword/createDocJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let str = filename?.split(separator: ".")
        
        let paramString = "filename=\(str![0])&input=\(transcriptionTV.text!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
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
    
    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 44
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = Bundle.main.loadNibNamed("FileHeaderCell", owner: self, options: nil)?.first as! FileHeaderCell
        
        headerView.headerLbl.text = "TRANSLATIONS"
        
        headerView.headerLbl.textColor = appDelegate.gray51
        
        let font1 = UIFont.init(name: "Avenir-Heavy", size: 16.0)
        
        headerView.headerLbl.font = font1
        
        headerView.leadingWidth.constant = 20
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let dict = translationsList[(indexPath as NSIndexPath).row] as! NSDictionary
        //
        //        did = dict.object(forKey: "did") as! String
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 75
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.translationsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        let dict = translationsList[(indexPath as NSIndexPath).row] as! NSDictionary
        
        cell.selectionStyle = .none
        
        let v0 = cell.viewWithTag(1) as! UILabel
        let v1 = cell.viewWithTag(2) as! UILabel
        let v2 = cell.viewWithTag(3) as! UIButton
        
        v0.text = dict.object(forKey: "displayLang") as? String
        //v1.text = dict.object(forKey: "language") as? String
        v1.text = ""
        
        //v2.setTitle(dict.object(forKey: "transcription") as? String, for: .normal)
        //v3.setTitle(dict.object(forKey: "translations") as? String, for: .normal)
        
        v2.restorationIdentifier = "\(indexPath.row)"
        
        return cell
    }
    
    // MARK: File management
    
    func createPDF() {
        
        let html = "<b>\(self.filename!)</i></b> <p>\(transcriptionTV.text!)</p>"
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
        let fileContentToWrite = transcriptionTV.text!
        
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
    
    @objc func doneClicked(sender: UIButton!) {
        
        self.view.endEditing(true)
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
    
    @IBAction func viewTranslation(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let ind = Int(btn.restorationIdentifier!)
        
        selectedFile = translationsList[ind!] as? NSDictionary
        
        did = selectedFile!.object(forKey: "did") as? String
        
        self.performSegue(withIdentifier: "EditTranslation", sender: self)
    }
    
    @IBAction func updateTranscription(_ sender: Any) {
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "TranslationOptions"
        {
            let destination = segue.destination as! TranslationOptions
            destination.did = did
            destination.filename = filename
            destination.content = content
        }
        else if segue.identifier == "EditTranslation"
        {
            let destination = segue.destination as! TranslationResult
            destination.did = did
            destination.filename = filename
            destination.selectedFile = selectedFile
        }
    }
}
