//
//  ConfirmTranslations.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/26/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class ConfirmTranslations: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var did : String?
    var filename: String?
    var displayStrings = [String]()
    var processInd : Int = 0
    var content : String?
    
    var languageList = NSMutableArray()
    var selectedLanguages = NSMutableArray()
    var selectedDisplayLanguages = NSMutableArray()
    var selectedDisplayLanguages2 = NSMutableArray()
    
    @IBOutlet weak var creditsLbl: UILabel!
    @IBOutlet weak var subtotalLbl: UILabel!
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var filenameLbl: UILabel!
    @IBOutlet weak var languageTable: UITableView!
    @IBOutlet weak var submitBtn: UIButton!
    var subtotal : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedDisplayLanguages2 = selectedDisplayLanguages
        
        activityView.isHidden = true
        languageTable.tableFooterView = UIView()
        languageTable.dataSource = self
        languageTable.delegate = self
        
        filenameLbl.text = "Translate File: \(filename!)"
        creditsLbl.text = "Remaining Credits: $\(self.appDelegate.credits!)"
        
        for lang in selectedDisplayLanguages
        {
            displayStrings.append("English->\(lang as! String)")
        }
        
        getCost()
        
        languageTable.reloadData()
    }
    
    func getCost () {
        
        let len1 = content!.count
        var rate = 0.0
        
        //$0.02 USD /THOUSAND CHAR
        //$0.10 USD /THOUSAND CHAR (custom)
        
        let chars = ceil( Double(len1 / 1000) ) * 1000
        
        let custom = false
        
        if ( custom ) {
            rate = 0.10;
        } else {
            rate = 0.02;
        }
        
        let markup = 5.0;
        let cost = ( chars / 1000 ) * rate
        var total = ( cost * markup ) + cost
        
        if ( total < 1 ) {
            total = 1;
        }
        
        total = Double(selectedDisplayLanguages.count) * total
        
        subtotalLbl.text = "Subtotal: $\(String(format: "%.2f", total))"
    }

    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //        let dict = fileList[(indexPath as NSIndexPath).row] as! NSDictionary
        //
        //        did = dict.object(forKey: "did") as! String
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.selectedLanguages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
        
        cell.selectionStyle = .none
        
        let str = "\(displayStrings[(indexPath as NSIndexPath).row])"
        
        let dict = str
        
        //cell.textLabel?.text = dict.object(forKey: "filename") as? String
        
        let v0 = cell.viewWithTag(1) as! UILabel
        
        //let code = dict.object(forKey: "code") as? String
        
        v0.text = dict
        
        return cell
    }
    
    // MARK: Web service
    
    func startProcessing () {
        
        print("startProcessing")
        
        let dataString = "translateData"
        
        let urlString = "\(appDelegate.serverDestination!)IBM-translate-bulk2.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let currentLang = selectedLanguages[processInd]
        let currentDisplayLang = selectedDisplayLanguages[processInd]
        
        let paramString = "uid=\(appDelegate.userid!)&language=\(currentLang)&displayLanguage=\(currentDisplayLang)&did=\(did!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        let str = "\(self.displayStrings[self.processInd]) - Processing"
        self.displayStrings[self.processInd] = str
        
        self.languageTable.reloadData()
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("bulk translation jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.activityView.isHidden = true
                        self.activityView.stopAnimating()
                        self.showBasicAlert(string: "Translation unsuccessful")
                    })
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    if (uploadData != nil)
                    {
                        //let status = uploadData.object(forKey: "status") as! String
                        let translationid = uploadData.object(forKey: "translationid") as! String
                        
                        print("translationid: \(translationid)")
                        
                        var str = self.displayStrings[self.processInd].replacingOccurrences(of: " - Processing", with: "")
                        
                        if translationid != "none"
                        {
                            str = "\(str) - Processed"
                        }
                        else
                        {
                            str = "\(str) - Failed"
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.displayStrings[self.processInd] = str
                            
                            self.languageTable.reloadData()
                            
                            self.processInd += 1
                            
                            if self.processInd < self.selectedLanguages.count
                            {
                                print("process next language")
                                self.startProcessing()
                            }
                            else
                            {
                                print("end of language list")
                                self.activityView.stopAnimating()
                                self.activityView.isHidden = true
                                NotificationCenter.default.post(name: Notification.Name("refreshTranslations1"), object: nil)

                                
                                let alert = UIAlertController(title: nil, message: "Translations completed", preferredStyle: UIAlertControllerStyle.alert)
                                
                                self.present(alert, animated: true, completion: nil)
                                
                                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                    switch action.style{
                                    case .default:
                                        print("default")
                                        
                                        self.returnToTranscription()
                                        
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
                            self.showBasicAlert(string: "Translation unsuccessful")
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
    
    func returnToTranscription() {
        
        NotificationCenter.default.post(name: Notification.Name("refreshTranslations"), object: nil)

        for controller in self.navigationController!.viewControllers as Array {

            if controller.isKind(of: TranscriptionResult.self) {

                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func submitOrder(_ sender: Any) {
        
        print("submit order")
        
        activityView.startAnimating()
        activityView.isHidden = false
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.gray74
        
        startProcessing()
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        selectedDisplayLanguages = selectedDisplayLanguages2
        
        dismiss()
    }
    
    func dismiss() {
        
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
