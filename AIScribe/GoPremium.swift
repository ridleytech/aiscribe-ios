//
//  GoPremium.swift
//  AIScribe
//
//  Created by Randall Ridley on 3/24/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class GoPremium: BaseViewController {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var submitBtn: UIButton!
    @IBOutlet weak var menuBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        activityView.isHidden = true
        
        menuBtn.addTarget(self, action: #selector(BaseViewController.onSlideMenuButtonPressed(_:)), for: UIControlEvents.touchUpInside)
    }
    
    @IBAction func goPremium(_ sender: Any) {
        
        submitBtn.isEnabled = false
        submitBtn.backgroundColor = appDelegate.crWarmGray
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        upgrade()
    }
    
    func upgrade () {
        
        activityView.isHidden = true
        activityView.stopAnimating()
        
        let debug = true
        
        if debug == false
        {
            updateUpgrade()
        }
        else
        {
            appDelegate.fullVersion = true
            
            //randall to do
            //save upgraded state in defaults and on server
            
            NotificationCenter.default.post(name: Notification.Name("appUpgraded"), object: nil)
            
            slideMenuItemSelectedAtIndex(0)
        }
    }
    
    func updateUpgrade() {
        
        print("updateUpgrade")
        
        let dataString = "groceryItemsData"
        
        let urlString = "\(appDelegate.serverDestination!)manageSingleGroceryItem.php"
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&selection=\(1)&devStatus=\(appDelegate.devStage!)"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("grocery jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.noResultsMain.isHidden = false
                    })
                }
                else
                {
                    let uploadData : NSDictionary = dataDict[dataString]! as! NSDictionary
                    let status = uploadData.object(forKey: "status") as! String
                    
                    var isSaved = false
                    
                    if status == "grocery items updated" || status == "grocery item added" || status == "substitution added" || status == "substitution removed" || status == "substitution updated"
                    {
                        isSaved = true
                    }
                    
                    DispatchQueue.main.sync(execute: {
                        
                        if isSaved == true
                        {
                            NotificationCenter.default.post(name: Notification.Name("appUpgraded"), object: nil)
                            
                            self.slideMenuItemSelectedAtIndex(0)
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
    
    @IBAction func done(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
}
