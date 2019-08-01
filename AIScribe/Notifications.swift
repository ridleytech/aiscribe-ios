


//
//  Notifications.swift
//  AIScribe
//
//  Created by DTO MacBook11 on 11/15/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class Notifications: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var statusLbl: UILabel!
    @IBOutlet weak var optionsTable: UITableView!
    
    var optionsList = [NSDictionary]()
    var selectedItems = [NSDictionary]()
    var prefsString : String?
    
    @IBOutlet weak var statusViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        optionsTable.delegate = self
        optionsTable.dataSource = self
        optionsTable.tableFooterView = UIView()
        
        optionsList.append(["title":"I receive a new friend request", "optionid":0])
        optionsList.append(["title":"A user accepts my friend invite", "optionid":1])
        optionsList.append(["title":"Someone adds a review on my recipe", "optionid":2])
        optionsList.append(["title":"Someone adds a review on a recipe I have reviewed", "optionid":3])
        optionsList.append(["title":"Someone adds a recipe to my Group", "optionid":4])
        optionsList.append(["title":"A friend invites me to a Group", "optionid":5])
        optionsList.append(["title":"A Group I am a member of has been deleted", "optionid":6])
        optionsList.append(["title":"Someone invites me to view their Meal Plan", "optionid":7])
        
        let attributedString = NSMutableAttributedString(string: "Notifications are currently disabled for AIScribe. To receive notifications, go to Settings.", attributes: [
            .font: UIFont(name: "Avenir-Light", size: 14.0)!,
            .foregroundColor: UIColor(white: 74.0 / 255.0, alpha: 1.0)
            ])
        attributedString.addAttributes([
            .font: UIFont(name: "Avenir-Heavy", size: 14.0)!,
            .foregroundColor: appDelegate.tomato
            ], range: NSRange(location: 84, length: 8))
        
        statusLbl.attributedText = attributedString
        
        statusViewHeight.constant = 0
        statusView.isHidden = true
        
        //getNotificationPrefs()
        
        optionsTable.reloadData()
    }
    
    @IBAction func disableAll(_ sender: Any) {
        
        if statusViewHeight.constant == 0
        {
            statusViewHeight.constant = 68
            statusView.isHidden = false
            selectedItems.removeAll()
        }
        else
        {
            statusViewHeight.constant = 0
            statusView.isHidden = true
        }
        
        optionsTable.reloadData()
    }
    
    @IBAction func save(_ sender: Any) {
        
        updatePrefs()
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        dismiss()
    }
    
    func dismiss () {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func getNotificationPrefs() {
        
        let urlString = "\(appDelegate.serverDestination!)notificationPrefs.php"
        
        print("getNotificationPrefs: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        //UIDevice.current.identifierForVendor!.uuidString
        
        let paramString = "uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        print("paramString: \(paramString)")
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            //print("Entered the completionHandler: \(response)")
            
            //var err: NSError?
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print("loginData: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                let uploadData : NSDictionary = dataDict.object(forKey: "prefsData") as! NSDictionary
                
                print("prefsData: \(uploadData)")
                
                if (uploadData != nil)
                {
                    self.prefsString = uploadData.object(forKey: "prefs") as? String
                    
                    let arr = self.prefsString?.split(separator: ",")
                    var arr2 = [String]()
                    
                    for a in arr!
                    {
                        arr2.append(String(a))
                    }
                    
                    for option in self.optionsList
                    {
                        if arr2.contains(option.object(forKey: "optionid") as! String)
                        {
                            self.selectedItems.append(option)
                        }
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        
                        if self.optionsList.count > 0
                        {
                            self.statusViewHeight.constant = 68
                            self.statusView.isHidden = false
                        }
                        
                        self.optionsTable.reloadData()
                    })
                }
                else
                {
                    self.showBasicAlert(string: "Please check your internet connection.")
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
                
                DispatchQueue.main.sync(execute: {
                    
                    self.showBasicAlert(string: "Please check your internet connection.")
                })
            }
            
        }.resume()
    }
    
    func updatePrefs() {
        
        //submitBtn.isEnabled = false
        
        //        activityView.isHidden = false
        //        activityView.startAnimating()
        
        print("uploadUserData")
        
        let urlString = "\(appDelegate.serverDestination!)notificationPrefs.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var selectedOptions = ""
        
        if selectedItems.count > 0
        {
            var optionids = ""
            var i = 0
            
            for a in selectedItems
            {
                if i == 0
                {
                    optionids = (a.object(forKey: "optionid") as? String)!
                }
                else
                {
                    optionids = "\(selectedOptions),\(a.object(forKey: "optionid") as! String)"
                }
                
                i += 1
            }
            
            selectedOptions = "\(optionids)"
        }
        
        let paramString = "\(selectedOptions)&update=true&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("add user jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["prefsData"]! is NSNull
                {
                    print("no user")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["prefsData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "prefs saved")
                    {
                        DispatchQueue.main.sync(execute: {
                            
//                            self.activityView.isHidden = true
//                            self.activityView.stopAnimating()
                            
                            //self.showBasicAlert(string: "Prefs saved.")
                            
                            self.dismiss()
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
//                            self.activityView.isHidden = true
//                            self.activityView.stopAnimating()
//
//                            self.submitBtn.isEnabled = true
//                            self.submitBtn.alpha = 1
                            
                            self.showBasicAlert(string: "Please check internet connection.")
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
    
    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if statusViewHeight.constant == 0
        {
            let item = optionsList[indexPath.row]
            
            if (selectedItems.contains(item)) {
                
                // found
                
                let ind = selectedItems.firstIndex(of: (item))
                selectedItems.remove(at: ind!)
                
            } else {
                
                // not
                
                selectedItems.append(item)
            }
            
            optionsTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.optionsList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0
        {
          return 74
        }
        else
        {
           return 42
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as? GroceryRecipeListCell
            
            return cell!
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell1")! as? NotificationOptionCell
            
            let dict = self.optionsList[(indexPath as NSIndexPath).row]
            
            let title = dict.object(forKey: "title")  as! String
            
            print("title: \(title)")
            
            cell!.selectionStyle = .none
            
            cell!.optionLbl.text = title
            
            //cell.selectBtn.restorationIdentifier = "\(indexPath.row)"
            //cell.selectBtn.addTarget(self, action: #selector(self.selectItem(_:)), for: UIControlEvents.touchUpInside)
            
            if (selectedItems.contains(dict)) {
                
                // found
                
                cell!.optionIV.image = UIImage.init(named: "checkGreen")
                
            } else {
                // not
                
                cell!.optionIV.image = UIImage.init(named: "unselected-1")
            }
            
            return cell!
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
