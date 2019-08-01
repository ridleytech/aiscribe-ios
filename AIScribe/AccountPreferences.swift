//
//  AccountPreferences.swift
//  AIScribe
//
//  Created by Randall Ridley on 1/2/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class AccountPreferences: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var cuisineCV: UICollectionView!
    
    var cuisines = [NSDictionary]()
    var selectedCuisines = [NSDictionary]()
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    @IBOutlet weak var submitBtn: UIButton!
    var newFamilyMemberID : Int?
    
    var concerns = [NSDictionary]()
    var selectedConcerns = [NSDictionary]()
    
    @IBOutlet weak var otherTxt: UITextField!
    
    //likes dislikes
    
    var likedItems = NSMutableArray()
    var dislikedItems = NSMutableArray()
    
    var category : String?
    
    var selectedList = NSMutableArray()
    var currentButtons = [UIButton]()
    var scrollButtons = [UIButton]()
    
    var buttonUnderscores = [UIView]()
    
    var fruitsList = NSMutableArray()
    var vegList = NSMutableArray()
    var meatList = NSMutableArray()
    var seafoodList = NSMutableArray()
    var dairyList = NSMutableArray()
    var nutsList = NSMutableArray()
    
    @IBOutlet weak var likesTable: UITableView!
    
    @IBOutlet weak var buttonScrollview: UIScrollView!
    
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var likesView: UIView!
    var viewIndex : Int = 0
    
    // MARK: viewDidLoad
    
    override func viewDidLoad() {
        
        //appDelegate.userid = "24"
        
        super.viewDidLoad()
        
        cuisineCV.delegate = self
        cuisineCV.dataSource = self
                
        likesView.isHidden = true
        cuisineCV.isHidden = false
        
        //otherTxt.isHidden = true
        activityView.isHidden = true
        
        //appDelegate.userid = "1"
        
        getCuisines()
        //populate()
        getAllConcerns()
        //getConcerns()
        getLikesDislikes()
        
        //query user added concerns
        
        //print("frame size: \(self.view.frame.width)")
        
//        var fontSize : CGFloat = 16.0
//
//        if self.view.frame.width <= 320
//        {
//            fontSize = 14.0
//        }
        
//        let attributedString = NSMutableAttributedString(string: "Step 2: Let us know your dietery concerns", attributes: [
//            .font: UIFont(name: "Avenir-Medium", size: fontSize)!,
//            .foregroundColor: UIColor.white
//            ])
//        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Book", size: fontSize)!, range: NSRange(location: 0, length: 7))
//
//        headerLbl.attributedText = attributedString
        
        
        let btnItem = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.done, target: self, action: #selector(dismissKeyboard))
        
        let numberToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width:  self.view.frame.size.width, height: 50))
        numberToolbar.backgroundColor = UIColor.darkGray
        numberToolbar.barStyle = UIBarStyle.default
        numberToolbar.tintColor = UIColor.black
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
            btnItem]
        
        numberToolbar.sizeToFit()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refeshConcerns),
                                               name: NSNotification.Name(rawValue: "refeshConcerns"),
                                               object: nil)
        
        //likes dislikes
        
        getIngredients()
        
        //selectedList = fruitsList
        
        category = "0"
        
        activityView.isHidden = true
        
        likesTable.delegate = self
        likesTable.dataSource = self
        likesTable.tableFooterView = UIView()
        
//        v2.isHidden = true
//        v3.isHidden = true
//        v4.isHidden = true
//        v5.isHidden = true
//        v6.isHidden = true
        
        //print("frame size: \(self.view.frame.width)")
        
//        var fontSize : CGFloat = 16.0
//        
//        if self.view.frame.width <= 320
//        {
//            fontSize = 14.0
//        }
//        
//        let attributedString = NSMutableAttributedString(string: "Step 3: Let us know your likes & dislikes", attributes: [
//            .font: UIFont(name: "Avenir-Medium", size: fontSize)!,
//            .foregroundColor: UIColor.white
//            ])
//        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Light", size: fontSize)!, range: NSRange(location: 0, length: 7))
//        
//        headerLbl.attributedText = attributedString
        
        //buttonView.isHidden = true
        
        populateButtonView()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(refreshIngredients),
                                               name: NSNotification.Name(rawValue: "refreshIngredients"),
                                               object: nil)
    }
    
    // MARK: Actions
    
    @IBAction func updateView(_ sender: Any) {
        
        let seg = sender as! UISegmentedControl
        
        viewIndex = seg.selectedSegmentIndex
        
        if viewIndex == 0 || viewIndex == 1
        {
            cuisineCV.reloadData()
            cuisineCV.isHidden = false
            likesView.isHidden = true
        }
        else
        {
            cuisineCV.isHidden = true
            likesView.isHidden = false
        }
    }
    
    @IBAction func savePreferences(_ sender: Any) {
        
    }
    
    @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    @IBAction func uploadData(_ sender: Any) {
        
        uploadAllData()
    }
    
    @objc func refreshIngredients (notification: NSNotification) {
        
        let newItems = notification.object as! [NSDictionary]
        
        //add new cats
        
        for dict in newItems
        {
            let ingredientID = dict.object(forKey: "ingredientid") as! String
            
            let dict = ["ingredient" : dict.object(forKey: "ingredient") as! String,"ingredientid": ingredientID,"categoryid": dict.object(forKey: "categoryid") as! String] as NSDictionary
            
            likedItems.add("\(ingredientID)-up")
            
            if dict.object(forKey: "categoryid") as! String == "1"
            {
                self.fruitsList.add(dict)
            }
            else if dict.object(forKey: "categoryid") as! String == "2"
            {
                self.vegList.add(dict)
            }
            else if dict.object(forKey: "categoryid") as! String == "3"
            {
                self.meatList.add(dict)
            }
            else if dict.object(forKey: "categoryid") as! String == "4"
            {
                self.seafoodList.add(dict)
            }
            else if dict.object(forKey: "categoryid") as! String == "5"
            {
                self.dairyList.add(dict)
            }
            else if dict.object(forKey: "categoryid") as! String == "6"
            {
                self.nutsList.add(dict)
            }
            
            //ind += 1
            
            self.selectedList.add(dict)
        }
        
        
        self.likesTable.reloadData()
    }
    
    @IBAction func showOptions(_ sender: Any) {
        
        let btn = sender as! UIButton
        let ind = Int(btn.accessibilityIdentifier!)
        
        var i = 0
        
        for view in buttonUnderscores
        {
            if i == ind
            {
                view.isHidden = false
            }
            else
            {
                view.isHidden = true
            }
            
            i += 1
        }
        
        if btn.restorationIdentifier == "b1"
        {
            //            v1.isHidden = false
            //            v2.isHidden = true
            //            v3.isHidden = true
            //            v4.isHidden = true
            //            v5.isHidden = true
            //            v6.isHidden = true
            
            selectedList = fruitsList
            
            category = "0"
        }
        else if btn.restorationIdentifier == "b2"
        {
            //            v1.isHidden = true
            //            v2.isHidden = false
            //            v3.isHidden = true
            //            v4.isHidden = true
            //            v5.isHidden = true
            //            v6.isHidden = true
            
            selectedList = vegList
            
            category = "1"
        }
        else if btn.restorationIdentifier == "b3"
        {
            //            v1.isHidden = true
            //            v2.isHidden = true
            //            v3.isHidden = false
            //            v4.isHidden = true
            //            v5.isHidden = true
            //            v6.isHidden = true
            
            selectedList = meatList
            
            category = "2"
        }
        else if btn.restorationIdentifier == "b4"
        {
            //            v1.isHidden = true
            //            v2.isHidden = true
            //            v3.isHidden = true
            //            v4.isHidden = false
            //            v5.isHidden = true
            //            v6.isHidden = true
            
            selectedList = seafoodList
            
            category = "3"
        }
        else if btn.restorationIdentifier == "b5"
        {
            //            v1.isHidden = true
            //            v2.isHidden = true
            //            v3.isHidden = true
            //            v4.isHidden = true
            //            v5.isHidden = false
            //            v6.isHidden = true
            
            selectedList = dairyList
            
            category = "4"
        }
        else if btn.restorationIdentifier == "b6"
        {
            //            v1.isHidden = true
            //            v2.isHidden = true
            //            v3.isHidden = true
            //            v4.isHidden = true
            //            v5.isHidden = true
            //            v6.isHidden = false
            
            selectedList = nutsList
            
            category = "5"
        }
        
        currentButtons.removeAll()
        
        likesTable.reloadData()
    }
    
    // MARK: Webservice
    
    func getAllConcerns() {
        
        //displayItems.removeAll()
        
        print("getAllConcerns")
        
        let dataString = "concernsData"
        
        let urlString = "\(appDelegate.serverDestination!)getAllConcerns.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        //appDelegate.userid = "22"
        
        let paramString = "devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("concerns jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.recipeStatusTV.isHidden = false
                        
                        self.cuisineCV.reloadData()
                    })
                }
                else
                {
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let recipes1 = uploadData as! [NSDictionary]
                    
                    var hasData = false
                    
                    if (recipes1.count > 0)
                    {
                        hasData = true
                        
                        for dict2 in recipes1
                        {
                            let name = dict2.object(forKey: "concernname" as String)!
                            let image = dict2.object(forKey: "imageblue" as String)!
                            let image2 = dict2.object(forKey: "imagewhite" as String)!
                            let concernid = dict2.object(forKey: "concernid" as String)!
                            
                            self.concerns.append( ["name" : name, "image" : UIImage.init(named: image as! String)!, "image2" : UIImage.init(named: image2 as! String)!,"concernid": concernid])
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if hasData == true
                            {
                                self.cuisineCV.reloadData()
                                
                                if self.newFamilyMemberID == nil && self.appDelegate.signingUp != true
                                {
                                    self.getUserConcerns()
                                }
                            }
                            else
                            {
                                print("no data")
                                
                                //self.noResultsMain.isHidden = false
                                
                                self.cuisineCV.reloadData()
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.cuisineCV.reloadData()
                            
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
    
    func getCuisines() {
        
        print("getCuisines")
        
        let dataString = "cuisineData"
        let dataString2 = "favoriteData"
        
        let urlString = "\(appDelegate.serverDestination!)getCuisinesProfile.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "register=true&devStatus=\(appDelegate.devStage!)&uid=\(appDelegate.userid!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                //print("cuisines jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        self.cuisineCV.isHidden = true
                        //self.recipeStatusTV.isHidden = false
                    })
                }
                else
                {
                    // parse cuisines
                    
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    let list1  = (uploadData["cuisines"]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let cuisines1 = list1 as! [NSDictionary]
                    
                    var hasData = false
                    
                    if (cuisines1.count > 0)
                    {
                        hasData = true
                        
                        for dict in cuisines1
                        {
                            let dict2 = dict.mutableCopy() as! NSMutableDictionary
                            
                            self.cuisines.append(dict2)
                        }
                        
                        //parse favorites
                        
                        let uploadData2 = dataDict[dataString2]! as! NSDictionary
                        
                        let list = (uploadData2["favorites"]! as! NSArray).mutableCopy() as! NSMutableArray
                        
                        let favorites1 = list as! [String]
                        
                        var ind = 0
                        
                        for _ in self.cuisines
                        {
                            let dict3 = self.cuisines[ind] as NSDictionary
                            
                            let cuisineid = dict3.object(forKey: "cuisineid") as! String
                            
                            if favorites1.contains(cuisineid)
                            {
                                self.selectedCuisines.append(dict3)
                            }
                            
                            ind += 1
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if hasData == true
                            {
                                self.cuisineCV.reloadData()
                            }
                            else
                            {
                                print("no data")
                                
                                self.cuisineCV.isHidden = true
                                //self.noResultsMain.isHidden = false
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
    }
    
    func getUserConcerns() {
        
        //displayItems.removeAll()
        
        print("getConcerns")
        
        let dataString = "concernsData"
        
        let urlString = "\(appDelegate.serverDestination!)getDietaryConcerns.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("concerns jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.recipeStatusTV.isHidden = false
                    })
                }
                else
                {
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                    let recipes1 = uploadData as! [String]
                    
                    var hasData = false
                    
                    if (recipes1.count > 0)
                    {
                        hasData = true
                        
                        var ind = 0
                        
                        for _ in self.concerns
                        {
                            let dict3 = self.concerns[ind] as NSDictionary
                            
                            let concernid = dict3.object(forKey: "concernid") as! String
                            
                            if recipes1.contains(concernid)
                            {
                                self.selectedConcerns.append(dict3)
                            }
                            
                            ind += 1
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if hasData == true
                            {
                                //self.cuisineCV.reloadData()
                                
                                
                                
                                //self.recipeStatusTV.text = "You currently have no recipes."
                                
                                //self.updateDisplayList()
                                
                                //self.cuisineCV.reloadData()
                            }
                            else
                            {
                                print("no data")
                                
                                //self.noResultsMain.isHidden = false
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
    }
    
    func getLikesDislikes() {
        
        //displayItems.removeAll()
        
        print("getLikesDislikes")
        
        let dataString = "likesData"
        
        let urlString = "\(appDelegate.serverDestination!)getUserFoodLikesProfile.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("likes jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict[dataString]! is NSNull {
                    
                    print("no data")
                    
                    DispatchQueue.main.sync(execute: {
                        
                        //self.recipeStatusTV.isHidden = false
                    })
                }
                else
                {
                    let uploadData = dataDict[dataString]! as! NSDictionary
                    
                    //var hasData = true
                    
                    let likes = uploadData.object(forKey: "likes") as! String
                    let dislikes = uploadData.object(forKey: "dislikes") as! String
                    
                    let likesArr = likes.split(separator: ",")
                    let dislikesArr = dislikes.split(separator: ",")
                    
                    for str in likesArr
                    {
                        self.likedItems.add("\(str)-up")
                    }
                    
                    for str in dislikesArr
                    {
                        self.dislikedItems.add("\(str)-down")
                    }
                    
                    //print("likedItems: \(self.likedItems)")
                    
//                    DispatchQueue.main.sync(execute: {
//
//                        if hasData == true
//                        {
//                            //self.cuisineCV.reloadData()
//                            //self.recipeStatusTV.text = "You currently have no recipes."
//                            //self.updateDisplayList()
//                        }
//                        else
//                        {
//                            print("no data")
//
//                            //self.noResultsMain.isHidden = false
//                        }
//                    })
                }
            }
            catch let err as NSError
            {
                print("error: \(err.description)")
            }
            
            }.resume()
    }
    
    func uploadLikesUserData() {
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadUserData")
        
        var likesString = ""
        var dislikesString = ""
        
        if likedItems.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in likedItems
            {
                if i == 0
                {
                    //cuisineids = (a.object(forKey: "concernid") as? String)!
                    
                    cuisineids = a as! String
                }
                else
                {
                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
                    cuisineids = "\(cuisineids),\(a as! String)"
                }
                
                i += 1
            }
            
            likesString = "\(cuisineids)"
        }
        
        if dislikedItems.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in dislikedItems
            {
                if i == 0
                {
                    //cuisineids = (a.object(forKey: "concernid") as? String)!
                    
                    cuisineids = a as! String
                }
                else
                {
                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
                    cuisineids = "\(cuisineids),\(a as! String)"
                }
                
                i += 1
            }
            
            dislikesString = "\(cuisineids)"
        }
        
        let urlString = "\(appDelegate.serverDestination!)manageUserFoodLikes.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        likesString = likesString.replacingOccurrences(of: "-up", with: "", options: .literal, range: nil)
        dislikesString = dislikesString.replacingOccurrences(of: "-down", with: "", options: .literal, range: nil)
        
        print("likesString: \(likesString)")
        print("dislikesString: \(dislikesString)")
        
        var paramString = ""
        
        if newFamilyMemberID != nil
        {
            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&familyid=\(newFamilyMemberID!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        else
        {
            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("likes jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["likesData"]! is NSNull
                {
                    print("no user")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                    
                    self.showBasicAlert(string: "no data")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["likesData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if status == "likes saved" || status == "likes updated"
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            if (self.self.appDelegate.signingUp == true)
                            {
                                self.performSegue(withIdentifier: "NutritionalGoals", sender: self)
                            }
                            else
                            {
                                self.showBasicAlert(string: "Likes/Dislikes Updated")
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            self.showBasicAlert(string: status)
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
    
    func getIngredients() {
        
        print("getIngredients")
        
        let dataString = "ingredientData"
        
        let urlString = "\(appDelegate.serverDestination!)getAllIngredients.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = ""
        
        print("urlString: \(urlString)")
        //print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("ingredients jsonResult: \(jsonResult)")
                
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
                        
                        let list = uploadData as! NSMutableArray
                        
                        for ob in list {
                            
                            let dict = ob as! NSDictionary
                            
                            //                            var fruitsList = NSMutableArray()
                            //                            var vegList = NSMutableArray()
                            //                            var meatList = NSMutableArray()
                            //                            var seafoodList = NSMutableArray()
                            //                            var dairyList = NSMutableArray()
                            //                            var nutsList = NSMutableArray()
                            
                            if dict.object(forKey: "categoryid") as! String == "1"
                            {
                                self.fruitsList.add(dict)
                            }
                            else if dict.object(forKey: "categoryid") as! String == "2"
                            {
                                self.vegList.add(dict)
                            }
                            else if dict.object(forKey: "categoryid") as! String == "3"
                            {
                                self.meatList.add(dict)
                            }
                            else if dict.object(forKey: "categoryid") as! String == "4"
                            {
                                self.seafoodList.add(dict)
                            }
                            else if dict.object(forKey: "categoryid") as! String == "5"
                            {
                                self.dairyList.add(dict)
                            }
                            else if dict.object(forKey: "categoryid") as! String == "6"
                            {
                                self.nutsList.add(dict)
                            }
                            //                            else if dict.object(forKey: "categoryid") as! String == "7"
                            //                            {
                            //                                fruitsList.add(dict)
                            //                            }
                            //                            else if dict.object(forKey: "categoryid") as! String == "8"
                            //                            {
                            //                                fruitsList.add(dict)
                            //                            }
                            //                            else if dict.object(forKey: "categoryid") as! String == "9"
                            //                            {
                            //                                fruitsList.add(dict)
                            //                            }
                            //                            else if dict.object(forKey: "categoryid") as! String == "10"
                            //                            {
                            //                                fruitsList.add(dict)
                            //                            }
                            
                        }
                        
                        self.selectedList = self.fruitsList
                        
                        DispatchQueue.main.sync(execute: {
                            
                            self.likesTable.reloadData()
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
    
    @objc func refeshConcerns (notification: NSNotification) {
        
        let newConcerns = notification.object as! [NSDictionary]
        
        //add new cats
        
        var ind = concerns.count-1
        
        concerns.remove(at: ind)
        
        for dict in newConcerns
        {
            let dict1 = ["name" : dict.object(forKey: "name") as! String, "image" : UIImage.init(named: "customWhite")!, "image2" : UIImage.init(named: "customWhite")!,"concernid": dict.object(forKey: "concernid") as! String] as [String : Any]
            
            concerns.append(dict1 as NSDictionary)
            selectedConcerns.append(dict1 as NSDictionary)
            
            ind += 1
        }
        
        concerns.append( ["name" : "Other", "image" : UIImage.init(named: "add")!, "image2" : UIImage.init(named: "add")!,"concernid": ind])
        
        cuisineCV.reloadData()
    }
    
    
    
    func uploadAllData () {
        
        var cuisineString = ""
        
        if selectedCuisines.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in selectedCuisines
            {
                if i == 0
                {
                    cuisineids = (a.object(forKey: "cuisineid") as? String)!
                }
                else
                {
                    cuisineids = "\(cuisineids),\(a.object(forKey: "cuisineid") as! String)"
                }
                
                i += 1
            }
            
            cuisineString = "\(cuisineids)"
        }
        
        var concernString = ""
        
        if selectedConcerns.count > 0
        {
            var concernids = [String]()
            //var i = 0
            
            for a in selectedConcerns
            {
                concernids.append((a.object(forKey: "concernid") as? String)!)
                
//                if i == 0
//                {
//                    concernids = (a.object(forKey: "concernid") as? String)!
//                }
//                else
//                {
//                    concernids = "\(concernids),\(a.object(forKey: "concernid") as! String)"
//                }
//
//                i += 1
            }
            
            concernString = "\(concernids.joined(separator: ","))"
        }
        
        
        var likesString = ""
        var dislikesString = ""
        
        if likedItems.count > 0
        {
//            var cuisineids = ""
//            var i = 0
            
            var cuisineids = [String]()
            
            for a in likedItems
            {
                cuisineids.append(a as! String)
                
//                if i == 0
//                {
//                    //cuisineids = (a.object(forKey: "concernid") as? String)!
//
//                    cuisineids = a as! String
//                }
//                else
//                {
//                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
//                    cuisineids = "\(cuisineids),\(a as! String)"
//                }
//
//                i += 1
            }
            
            //likesString = "\(cuisineids)"
            likesString = "\(cuisineids.joined(separator: ","))"
        }
        
        if dislikedItems.count > 0
        {
            var cuisineids = [String]()
            
//            var cuisineids = ""
//            var i = 0
            
            for a in dislikedItems
            {
                cuisineids.append(a as! String)
                
//                if i == 0
//                {
//                    //cuisineids = (a.object(forKey: "concernid") as? String)!
//
//                    cuisineids = a as! String
//                }
//                else
//                {
//                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
//                    cuisineids = "\(cuisineids),\(a as! String)"
//                }
//
//                i += 1
            }
            
            //dislikesString = "\(cuisineids)"
            dislikesString = "\(cuisineids.joined(separator: ","))"
        }
        
        if concernString == ""
        {
            concernString = "8,23"
        }
        
        let urlString = "\(appDelegate.serverDestination!)manageUserAccountPrefsData.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        likesString = likesString.replacingOccurrences(of: "-up", with: "", options: .literal, range: nil)
        dislikesString = dislikesString.replacingOccurrences(of: "-down", with: "", options: .literal, range: nil)
        
        print("likesString: \(likesString)")
        print("dislikesString: \(dislikesString)")
        
        let paramString = "likes=\(likesString)&dislikes=\(dislikesString)&concerns=\(concernString)&cuisines=\(cuisineString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        
//        if newFamilyMemberID != nil
//        {
//            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&concernString=\(concernString)&cuisineString=\(cuisineString)&familyid=\(newFamilyMemberID!)&devStatus=\(appDelegate.devStage!)"
//        }
//        else
//        {
//            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&concerns=\(concernString)&cuisines=\(cuisineString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)"
//        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("prefsData jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["prefsData"]! is NSNull
                {
                    print("no user")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                    
                    self.showBasicAlert(string: "no data")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["prefsData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if status == "3"
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
//                            self.submitBtn.isEnabled = true
//                            self.submitBtn.alpha = 1
                            
                            self.showBasicAlert(string: "Dietary Preferences Updated")
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            //self.showBasicAlert(string: status)
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
    
    func uploadConcerns() {
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadConcerns")
        
        var concernString = ""
        
        if selectedConcerns.count > 0
        {
            var concernids = ""
            var i = 0
            
            for a in selectedConcerns
            {
                if i == 0
                {
                    concernids = (a.object(forKey: "concernid") as? String)!
                }
                else
                {
                    concernids = "\(concernids),\(a.object(forKey: "concernid") as! String)"
                }
                
                i += 1
            }
            
            concernString = "\(concernids)"
        }
        
        let urlString = "\(appDelegate.serverDestination!)manageDietaryConcerns.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var paramString = ""
        
        if newFamilyMemberID != nil
        {
            paramString = "selections=\(concernString)&familyid=\(newFamilyMemberID!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        else
        {
            paramString = "selections=\(concernString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("cuisines jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["favoriteData"]! is NSNull
                {
                    print("no user")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                    
                    self.showBasicAlert(string: "no data")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["favoriteData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if status == "user dietary concerns saved" || status == "user dietary concerns saved" || status == "user dietary concerns updated"
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            if (self.self.appDelegate.signingUp == true)
                            {
                                self.performSegue(withIdentifier: "LikesDislikes", sender: self)
                            }
                            else
                            {
                                self.showBasicAlert(string: "Dietary Concerns Updated")
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            //self.showBasicAlert(string: status)
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
    
    func uploadCuisines() {
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadCuisines")
        
        var cuisineString = ""
        
        if selectedCuisines.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in selectedCuisines
            {
                if i == 0
                {
                    cuisineids = (a.object(forKey: "cuisineid") as? String)!
                }
                else
                {
                    cuisineids = "\(cuisineids),\(a.object(forKey: "cuisineid") as! String)"
                }
                
                i += 1
            }
            
            cuisineString = "\(cuisineids)"
        }
        
        let urlString = "\(appDelegate.serverDestination!)manageFavoriteCuisines.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        var paramString = ""
        
        if newFamilyMemberID != nil
        {
            paramString = "selections=\(cuisineString)&familyid=\(newFamilyMemberID!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        else
        {
            paramString = "selections=\(cuisineString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("cuisines jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["favoriteData"]! is NSNull
                {
                    print("no user")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["favoriteData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if (status == "usercuisines saved" || status == "usercuisines updated")
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            if (self.self.appDelegate.signingUp == true)
                            {
                                self.performSegue(withIdentifier: "DietaryConcerns", sender: self)
                            }
                            else
                            {
                                self.showBasicAlert(string: "Cusines Updated")
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            //self.showBasicAlert(string: status)
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
    
    func uploadLikesDislikes() {
        
        submitBtn.isEnabled = false
        
        activityView.isHidden = false
        activityView.startAnimating()
        
        print("uploadUserData")
        
        var likesString = ""
        var dislikesString = ""
        
        if likedItems.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in likedItems
            {
                if i == 0
                {
                    //cuisineids = (a.object(forKey: "concernid") as? String)!
                    
                    cuisineids = a as! String
                }
                else
                {
                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
                    cuisineids = "\(cuisineids),\(a as! String)"
                }
                
                i += 1
            }
            
            likesString = "\(cuisineids)"
        }
        
        if dislikedItems.count > 0
        {
            var cuisineids = ""
            var i = 0
            
            for a in dislikedItems
            {
                if i == 0
                {
                    //cuisineids = (a.object(forKey: "concernid") as? String)!
                    
                    cuisineids = a as! String
                }
                else
                {
                    //cuisineids = "\(cuisineids),\(a.object(forKey: "concernid") as! String)"
                    cuisineids = "\(cuisineids),\(a as! String)"
                }
                
                i += 1
            }
            
            dislikesString = "\(cuisineids)"
        }
        
        let urlString = "\(appDelegate.serverDestination!)manageUserFoodLikes.php"
        
        print("urlString: \(urlString)")
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        likesString = likesString.replacingOccurrences(of: "-up", with: "", options: .literal, range: nil)
        dislikesString = dislikesString.replacingOccurrences(of: "-down", with: "", options: .literal, range: nil)
        
        print("likesString: \(likesString)")
        print("dislikesString: \(dislikesString)")
        
        var paramString = ""
        
        if newFamilyMemberID != nil
        {
            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&familyid=\(newFamilyMemberID!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        else
        {
            paramString = "likes=\(likesString)&dislikes=\(dislikesString)&uid=\(appDelegate.userid!)&devStatus=\(appDelegate.devStage!)&mobile=true"
        }
        
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("likes jsonResult: \(jsonResult)")
                
                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
                
                if dataDict["likesData"]! is NSNull
                {
                    print("no user")
                    
                    self.activityView.isHidden = true
                    self.activityView.stopAnimating()
                    
                    self.submitBtn.isEnabled = true
                    self.submitBtn.alpha = 1
                    
                    self.showBasicAlert(string: "no data")
                }
                else
                {
                    let userDict : NSDictionary = dataDict["likesData"] as! NSDictionary
                    
                    let status : String = userDict["status"] as! String
                    
                    print("status: \(status)")
                    
                    if status == "likes saved" || status == "likes updated"
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            if (self.self.appDelegate.signingUp == true)
                            {
                                self.performSegue(withIdentifier: "NutritionalGoals", sender: self)
                            }
                            else
                            {
                                self.showBasicAlert(string: "Likes/Dislikes Updated")
                            }
                        })
                    }
                    else
                    {
                        DispatchQueue.main.sync(execute: {
                            
                            self.activityView.isHidden = true
                            self.activityView.stopAnimating()
                            
                            self.submitBtn.isEnabled = true
                            self.submitBtn.alpha = 1
                            
                            self.showBasicAlert(string: status)
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
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let kWhateverHeightYouWant = 190
        
        return CGSize.init(width: 600, height: CGFloat(kWhateverHeightYouWant))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if viewIndex == 0
        {
            return self.cuisines.count
        }
        else
        {
            return self.concerns.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if viewIndex == 0
        {
            let dict = self.cuisines[indexPath.row] as! NSDictionary
            
            //let id = dict.object(forKey: "cuisineid") as! String
            let name = dict.object(forKey: "cuisinename") as! String
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CuisinesCollectionviewCell
            
            cell?.cuisineLbl.text = name
            
            if selectedCuisines.contains(dict)
            {
                cell?.cuisineLbl.backgroundColor = appDelegate.crLightBlue
                cell?.cuisineLbl.textColor = UIColor.white
            }
            else
            {
                cell?.cuisineLbl.backgroundColor = UIColor.white
                cell?.cuisineLbl.textColor = appDelegate.crLightBlue
            }
            
            cell?.cuisineLbl.layer.borderWidth = 1.0
            cell?.cuisineLbl.layer.borderColor = appDelegate.crLightBlue.cgColor
            cell?.cuisineLbl.layer.cornerRadius = 4.0
            
            //cell?.statusLbl.isHidden = true
            
            return cell!
        }
        else
        {
            let dict = self.concerns[indexPath.row]
            
            let string = dict.object(forKey: "name") as! String
            let img = dict.object(forKey: "image") as! UIImage
            let img2 = dict.object(forKey: "image2") as! UIImage
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell2", for: indexPath) as? CuisinesCollectionviewCell
            
            cell?.cuisineLbl.text = string
            cell?.iconIV.image = img
            
            if selectedConcerns.contains(dict)
            {
                cell?.backgroundColor = appDelegate.crLightBlue
                cell?.cuisineLbl.textColor = UIColor.white
                cell?.iconIV.image = img2
            }
            else
            {
                cell?.backgroundColor = UIColor.white
                cell?.cuisineLbl.textColor = appDelegate.crLightBlue
            }
            
            cell?.layer.borderWidth = 1.0
            cell?.layer.borderColor = appDelegate.crLightBlue.cgColor
            cell?.layer.cornerRadius = 4.0
            
            return cell!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if viewIndex == 0
        {
            let dict = self.cuisines[indexPath.row] as! NSDictionary
            
            //let id = dict.object(forKey: "cuisineid") as! String
            //        let name = dict.object(forKey: "cuisinename") as! String
            //
            //        print("cuisinename: \(name)")
            
            if selectedCuisines.contains(dict)
            {
                let ind = selectedCuisines.firstIndex(of: dict)
                selectedCuisines.remove(at: ind!)
            }
            else
            {
                selectedCuisines.append(dict)
            }
            
            print("selectedCuisines: \(selectedCuisines)")
            
            cuisineCV.reloadData()
        }
        else
        {
            if indexPath.row == concerns.count-1
            {
                performSegue(withIdentifier: "AddConcern", sender: nil)
            }
            else
            {
                let dict = self.concerns[indexPath.row]
                
                //let id = dict.object(forKey: "cuisineid") as! String
                //        let name = dict.object(forKey: "cuisinename") as! String
                //
                //        print("cuisinename: \(name)")
                
                if selectedConcerns.contains(dict)
                {
                    let ind = selectedConcerns.firstIndex(of: dict)
                    selectedConcerns.remove(at: ind!)
                }
                else
                {
                    selectedConcerns.append(dict)
                }
                
                print("selectedConcerns: \(selectedConcerns)")
                
                cuisineCV.reloadData()
            }
        }
    }
    
    // MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
    }
    
    @IBAction func goBack(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
    }
    
    func populateButtonView () {
        
        var xPos = 0
        let lbls = ["Fruits","Vegetables","Meat","Seafood","Dairy","Nuts, Beans &\nOther Protein"]
        
        var width = 65
        
        for i : Int in 0 ..< lbls.count
        {
            
            if i == 5
            {
                width = 80
            }
            else
            {
                width = 65
            }
            
            let doneButton3 = UIButton(frame: CGRect(x: xPos, y: 0, width: width, height: 34))
            doneButton3.setTitle(lbls[i], for: .normal)
            doneButton3.addTarget(self, action: #selector(self.showOptions(_:)), for: UIControlEvents.touchUpInside)
            doneButton3.restorationIdentifier = "b\(i+1)"
            doneButton3.accessibilityIdentifier = String(i)
            buttonScrollview.addSubview(doneButton3)
            
            let f = UIFont(name: "Avenir-Book", size: 12.0)
            
            doneButton3.titleLabel?.font = f
            doneButton3.titleLabel?.numberOfLines = 0
            doneButton3.setTitleColor(appDelegate.crLightBlue, for: .normal)
            
            let view = UIButton(frame: CGRect(x: xPos, y: 36, width: width, height: 2))
            view.backgroundColor = appDelegate.crLightBlue
            buttonScrollview.addSubview(view)
            buttonUnderscores.append(view)
            
            if i > 0
            {
                view.isHidden = true
            }
            
            xPos = xPos + width
        }
        
        buttonScrollview.contentSize = CGSize.init(width: lbls.count*75, height: 42)
    }
    
    // MARK: Tableview
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
         return self.selectedList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell : LikesTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! LikesTableViewCell
        
        let dict = self.selectedList[(indexPath as NSIndexPath).row] as! NSDictionary
        
        let id = dict.object(forKey: "ingredientid") as? String
        var val = dict.object(forKey: "ingredient") as? String
        
        val = val!.replacingOccurrences(of: "\"", with: "", options: .literal, range: nil)
        val = val!.replacingOccurrences(of: "/", with: "", options: .literal, range: nil)
        val = val!.replacingOccurrences(of: "\\u2019", with: "'", options: .literal, range: nil)
        
        cell.likeBtn?.setBackgroundImage(UIImage.init(named: "gray-up"), for: .normal)
        cell.dislikeBtn.setBackgroundImage(UIImage.init(named: "gray"), for: .normal)
        
        cell.itemLbl?.text = val!
        cell.selectionStyle = .none
        
        let likeRestVal = "\(id!)-up"
        let dislikeRestVal = "\(id!)-down"
        
        cell.likeBtn?.restorationIdentifier = likeRestVal
        cell.dislikeBtn?.restorationIdentifier = dislikeRestVal
        
        if likedItems.contains(likeRestVal)
        {
            cell.likeBtn?.setBackgroundImage(UIImage.init(named: "green"), for: .normal)
        }
        else if dislikedItems.contains(dislikeRestVal)
        {
            cell.dislikeBtn?.setBackgroundImage(UIImage.init(named: "red"), for: .normal)
        }
        
        cell.likeBtn?.addTarget(self, action: #selector(self.likeItem(_:)), for: UIControlEvents.touchUpInside)
        cell.dislikeBtn?.addTarget(self, action: #selector(self.dislikeItem(_:)), for: UIControlEvents.touchUpInside)
        
        currentButtons.append(cell.likeBtn)
        currentButtons.append(cell.dislikeBtn)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //println("You selected cell #\(indexPath.row)!")
        
        //selectedIem = self.items[(indexPath as NSIndexPath).row]
        
        //self.performSegue(withIdentifier: "GoToCategoryCards", sender: self)
    }
    
    @objc func likeItem(_ sender : UIButton) {
        
        let btn = sender as UIButton
        let val = btn.restorationIdentifier
        
        if likedItems.contains(val!)
        {
            likedItems.remove(val!)
            btn.setBackgroundImage(UIImage.init(named: "gray-up"), for: .normal)
        }
        else
        {
            likedItems.add(val!)
            btn.setBackgroundImage(UIImage.init(named: "green"), for: .normal)
            
            if dislikedItems.contains(val!)
            {
                dislikedItems.remove(val!)
            }
            
            let prefix = val?.split(separator: "-")
            
            for btn1 in self.currentButtons {
                
                if btn1.restorationIdentifier == "\(prefix![0])-down"
                {
                    //print("set to gray")
                    dislikedItems.remove("\(prefix![0])-down")
                    btn1.setBackgroundImage(UIImage.init(named: "gray"), for: .normal)
                }
            }
        }
        
        print("likedItems: \(likedItems)")
        print("dislikedItems: \(dislikedItems)")
    }
    
    @objc func dislikeItem(_ sender : UIButton) {
        
        let btn = sender as UIButton
        let val = btn.restorationIdentifier
        
        if dislikedItems.contains(val!)
        {
            dislikedItems.remove(val!)
            btn.setBackgroundImage(UIImage.init(named: "gray"), for: .normal)
        }
        else
        {
            dislikedItems.add(val!)
            btn.setBackgroundImage(UIImage.init(named: "red"), for: .normal)
            
            if likedItems.contains(val!)
            {
                likedItems.remove(val!)
            }
            
            let prefix = val?.split(separator: "-")
            
            for  btn1 in self.currentButtons {
                
                if btn1.restorationIdentifier == "\(prefix![0])-up"
                {
                    likedItems.remove("\(prefix![0])-up")
                    //print("set to gray")
                    btn1.setBackgroundImage(UIImage.init(named: "gray-up"), for: .normal)
                }
            }
        }
        
        print("likedItems: \(likedItems)")
        print("dislikedItems: \(dislikedItems)")
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
    
    func populate () {
        
        concerns.append( ["name" : "Diabetic", "image" : UIImage.init(named: "noSugarBlue")!, "image2" : UIImage.init(named: "noSugarWhite")!,"concernid": "1"])
        concerns.append( ["name" : "Dairy Allergy", "image" : UIImage.init(named: "dairyAllergyBlue")!, "image2" : UIImage.init(named: "dairyAllergyWhite")!,"concernid": "2"])
        concerns.append( ["name" : "Egg Allergy", "image" : UIImage.init(named: "eggAllergyBlue")!, "image2" : UIImage.init(named: "eggAllergyWhite")!,"concernid": "3"])
        concerns.append( ["name" : "Fish Allergy", "image" : UIImage.init(named: "fishAllergyBlue")!, "image2" : UIImage.init(named: "fishAllergyWhite")!,"concernid": "4"])
        concerns.append( ["name" : "Flexitarian", "image" : UIImage.init(named: "flexitarianBlue")!, "image2" : UIImage.init(named: "flexitarianWhite")!,"concernid": "5"])
        concerns.append( ["name" : "Gluten Intolerance", "image" : UIImage.init(named: "glutenIntoleranceBlue")!, "image2" : UIImage.init(named: "glutenIntoleranceWhite")!,"concernid": "6"])
        concerns.append( ["name" : "Halal", "image" : UIImage.init(named: "halalBlue")!, "image2" : UIImage.init(named: "halalWhite")!,"concernid": "7"])
        concerns.append( ["name" : "Heart Healthy", "image" : UIImage.init(named: "heartHealthyBlue")!, "image2" : UIImage.init(named: "heartHealthyWhite")!,"concernid": "8"])
        concerns.append( ["name" : "Keto", "image" : UIImage.init(named: "ketoBlue")!, "image2" : UIImage.init(named: "ketoWhite")!,"concernid": "9"])
        concerns.append( ["name" : "Kosher", "image" : UIImage.init(named: "kosherBlue")!, "image2" : UIImage.init(named: "kosherWhite")!,"concernid": "10"])
        concerns.append( ["name" : "Lacto Vegitarian", "image" : UIImage.init(named: "lactoVegetarianBlue")!, "image2" : UIImage.init(named: "lactoVegetarianWhite")!,"concernid": "11"])
        concerns.append( ["name" : "Lactose Intolerant", "image" : UIImage.init(named: "lactoseIntoleranceBlue")!, "image2" : UIImage.init(named: "lactoseIntoleranceWhite")!,"concernid": "12"])
        concerns.append( ["name" : "Low Carb", "image" : UIImage.init(named: "lowCarbBlue")!, "image2" : UIImage.init(named: "lowCarbWhite")!,"concernid": "13"])
        concerns.append( ["name" : "Low Fat", "image" : UIImage.init(named: "lowFatBlue")!, "image2" : UIImage.init(named: "lowFatWhite")!,"concernid": "14"])
        concerns.append( ["name" : "Low Sodium", "image" : UIImage.init(named: "lowSodiumBlue")!, "image2" : UIImage.init(named: "lowSodiumWhite")!,"concernid": "15"])
        concerns.append( ["name" : "Low Sugar", "image" : UIImage.init(named: "lowSugarBlue")!, "image2" : UIImage.init(named: "lowSugarWhite")!,"concernid": "16"])
        concerns.append( ["name" : "Ovo Vegetarian", "image" : UIImage.init(named: "ovoVegetarianBlue")!, "image2" : UIImage.init(named: "ovoVegetarianWhite")!,"concernid": "17"])
        concerns.append( ["name" : "Paleo", "image" : UIImage.init(named: "paleoBlue")!, "image2" : UIImage.init(named: "paleoWhite")!,"concernid": ""])
        concerns.append( ["name" : "Peanut Allergy", "image" : UIImage.init(named: "peanutAllergyBlue")!, "image2" : UIImage.init(named: "peanutAllergyWhite")!,"concernid": "18"])
        concerns.append( ["name" : "Pescetarian", "image" : UIImage.init(named: "pescetarianBlue")!, "image2" : UIImage.init(named: "pescetarianWhite")!,"concernid": "19"])
        concerns.append( ["name" : "Shellfish Allergy", "image" : UIImage.init(named: "shellfishAllergyBlue")!, "image2" : UIImage.init(named: "shellfishAllergyWhite")!,"concernid": "20"])
        concerns.append( ["name" : "Soy Allergy", "image" : UIImage.init(named: "soyAllergyBlue")!, "image2" : UIImage.init(named: "soyAllergyWhite")!,"concernid": "21"])
        concerns.append( ["name" : "Vegan", "image" : UIImage.init(named: "veganBlue")!, "image2" : UIImage.init(named: "veganWhite")!,"concernid": ""])
        concerns.append( ["name" : "Vegetarian", "image" : UIImage.init(named: "vegetarianBlue")!, "image2" : UIImage.init(named: "vegetarianWhite")!,"concernid": "22"])
        concerns.append( ["name" : "Wheat Allergy", "image" : UIImage.init(named: "wheatAllergyBlue")!, "image2" : UIImage.init(named: "wheatAllergyWhite")!,"concernid": "23"])
        concerns.append( ["name" : "Other", "image" : UIImage.init(named: "add")!, "image2" : UIImage.init(named: "add")!,"concernid": "24"])
        
        cuisineCV.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
