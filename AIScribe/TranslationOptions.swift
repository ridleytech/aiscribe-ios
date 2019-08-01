//
//  TranslationList.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/25/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class TranslationOptions: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var did : String?
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var languageList = NSMutableArray()
    var selectedLanguages = NSMutableArray()
    var selectedDisplayLanguages = NSMutableArray()
    var filename: String?
    var content : String?
    @IBOutlet weak var languageTable: UITableView!

    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityView.startAnimating()
        
        languageTable.tableFooterView = UIView()
        languageTable.dataSource = self
        languageTable.delegate = self

        submitBtn.backgroundColor = appDelegate.crWarmGray
        submitBtn.isEnabled = false

        getLanguages()

        // Do any additional setup after loading the view.
    }
    
    func getLanguages() {
        
        print("getLanguages")
        
        let dataString = "languageData"
        
        let urlString = "\(appDelegate.serverDestination!)getLanguages.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "mobile=true&did=\(did!)&devStatus=\(appDelegate.devStage!)"
        
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
                            self.languageTable.reloadData()
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
        
        //        let dict = fileList[(indexPath as NSIndexPath).row] as! NSDictionary
        //
        //        did = dict.object(forKey: "did") as! String
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            
            // handle delete (by removing the data from your array and updating the tableview)
            
            //            removeObject = currentItemArray[indexPath.row]
            //
            //            currentItemArray.remove(at: indexPath.row)
            //            itemArray.removeAll(where: { $0.signalid == removeObject?.signalid })
            //
            //            tableView.deleteRows(at: [indexPath], with: .fade)
            //
            //            removeSignal()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 65
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.languageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! 
        
        cell.selectionStyle = .none
        
        let dict = languageList[(indexPath as NSIndexPath).row] as! NSDictionary
        
        //cell.textLabel?.text = dict.object(forKey: "filename") as? String
        
        let v0 = cell.viewWithTag(1) as! UILabel
        let v2 = cell.viewWithTag(2) as! UIButton
        
        let code = dict.object(forKey: "code") as? String
        let translated = dict.object(forKey: "translated") as? Int
        
        let displayName = dict.object(forKey: "displayname") as? String
        
        v0.text = displayName
        v2.restorationIdentifier = "\(code!)"
        v2.accessibilityHint = displayName
        
        if translated == 1
        {
            v2.isEnabled = false
            v2.alpha = 0.5
            v2.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            //v2.backgroundColor = .lightGray
        }
        else
        {
            v2.isEnabled = true
            v2.alpha = 1.0
            v2.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            //v2.backgroundColor = .clear
        }
        
        //let rating = dict.object(forKey: "rating") as! String
        
        //        if indexPath.row % 2 == 0
        //        {
        //            cell.backgroundColor = appDelegate.whitefive
        //        }
        //        else
        //        {
        //            cell.backgroundColor = .white
        //        }
        
        return cell
    }
    
    @IBAction func manageCode(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let code = btn.restorationIdentifier!
        let dl = btn.accessibilityHint!
        
        if selectedLanguages.contains(code)
        {
            selectedLanguages.remove(code)
            selectedDisplayLanguages.remove(dl)
            btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
        }
        else
        {
            selectedLanguages.add(code)
            selectedDisplayLanguages.add(dl)
            btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
        }
        
        if selectedLanguages.count > 0
        {
            submitBtn.isEnabled = true
            submitBtn.backgroundColor = appDelegate.crLightBlue
        }
        else
        {
            submitBtn.isEnabled = false
            submitBtn.backgroundColor = appDelegate.crWarmGray
        }
        
        print("selectedDisplayLanguages: \(selectedDisplayLanguages)")
        
        //languageTable.reloadData()
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ConfirmTranslations"
        {
            let destination = segue.destination as! ConfirmTranslations
            destination.did = did
            destination.content = content
            destination.selectedLanguages = selectedLanguages
            destination.selectedDisplayLanguages = selectedDisplayLanguages
            destination.filename = filename
        }
    }
}
