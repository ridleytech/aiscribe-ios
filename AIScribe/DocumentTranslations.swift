//
//  DocumentTranslations.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/27/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class DocumentTranslations: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var menuBtn: UIButton!
    @IBOutlet weak var filenameLbl: UILabel!
    var did : String?
    var filename: String?
    var translationsList = NSMutableArray()
    var selectedFile: NSDictionary?
    
    @IBOutlet weak var translationTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        translationTable.tableFooterView = UIView()
        translationTable.dataSource = self
        translationTable.delegate = self
        
        filenameLbl.text = filename
        
        activityView.startAnimating()
        getTranslations()
        
        // Do any additional setup after loading the view.
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshTranslationsNotification),
            name: NSNotification.Name(rawValue: "refreshTranslations"),
            object: nil)
    }
    
    @objc func refreshTranslationsNotification (notification: NSNotification) {
        
        print("handle")
        
        translationsList.removeAllObjects()
        
        getTranslations()
    }
    
    func getTranslations() {
        
        print("getTranslations")
        
        let dataString = "translationData"
        
        let urlString = "\(appDelegate.serverDestination!)documentTranslationsJSON.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "did=\(did!)&mobile=true&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        //print("paramString: \(paramString)")
        
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
    
    // MARK: Tableview
    
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
        v1.text = dict.object(forKey: "language") as? String
        //v2.setTitle(dict.object(forKey: "transcription") as? String, for: .normal)
        //v3.setTitle(dict.object(forKey: "translations") as? String, for: .normal)
        
        v2.restorationIdentifier = "\(indexPath.row)"
        
        return cell
    }
    
    @IBAction func viewTranslation(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let ind = Int(btn.restorationIdentifier!)
        
        selectedFile = translationsList[ind!] as? NSDictionary
        
        did = selectedFile!.object(forKey: "did") as? String
        
        self.performSegue(withIdentifier: "EditTranslation", sender: self)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "EditTranslation"
        {
            let destination = segue.destination as! TranslationResult
            destination.did = did
            destination.filename = filename
            destination.selectedFile = selectedFile
        }
    }
}
