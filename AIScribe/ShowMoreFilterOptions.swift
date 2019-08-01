//
//  ShowMoreFilterOptions.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/8/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class ShowMoreFilterOptions: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var activityView: UIActivityIndicatorView!
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var otherTxt: UITextField!
    
    var category : String?
    var isUpdating: Bool?
    
    //var labelList = ["Calories"]
//    var dietsList = ["Diabetic","Dairy Allergy"]
//    var cuisinesList = ["American"]
//    var ingredientsList = ["Vegetables"]
    
    
    
    var mealLabelList = NSMutableArray()
    var dietLabelList = NSMutableArray()
    var ingredientLabelList = NSMutableArray()
    var cuisineLabelList = NSMutableArray()
    var selectedLabelList : NSMutableArray?
    
    var selectedList : NSMutableArray?
    var selectedDiets : NSMutableArray?
    var selectedMeals : NSMutableArray?
    var selectedCuisines : NSMutableArray?
    var selectedIngredients : NSMutableArray?
    
    @IBOutlet weak var likesTable: UITableView!
    
    var numberToolbar : UIToolbar?
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        likesTable.delegate = self
        likesTable.dataSource = self
        
        activityView.isHidden = true
        
        likesTable.allowsMultipleSelection = true
        
        dietLabelList.add("Diabetic")
        dietLabelList.add("Dairy Allergy")
        dietLabelList.add("Egg Allergy")
        dietLabelList.add("Fish Allergy")
        dietLabelList.add("Flexitarian")
        dietLabelList.add("Gluten Intolerance")
        
        mealLabelList.add("Breakfast")
        mealLabelList.add("Lunch")
        mealLabelList.add("Snack")
        mealLabelList.add("Dinner")
        mealLabelList.add("Dessert")
        
        cuisineLabelList.add("Afghan")
        cuisineLabelList.add("American")
        cuisineLabelList.add("Argentinian")
        
        ingredientLabelList.add("Vegatables")
        ingredientLabelList.add("Chicken")
        ingredientLabelList.add("Pasta")
        
        
//        let attributedString = NSMutableAttributedString(string: "More Options", attributes: [
//            .font: UIFont(name: "Avenir-Medium", size: 16.0)!,
//            .foregroundColor: UIColor.white
//            ])
//        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Light", size: 16.0)!, range: NSRange(location: 0, length: 7))
//
//        headerLbl.attributedText = attributedString
        
        if category == "Diets"
        {
            selectedList = selectedDiets!
            selectedLabelList = dietLabelList
            
            headerLbl.text = "Diet Options"
        }
        else if category == "Cuisines"
        {
            selectedList = selectedCuisines!
            selectedLabelList = cuisineLabelList
            
            headerLbl.text = "Cuisine Options"
        }
        else if category == "Ingredients"
        {
            selectedList = selectedIngredients!
            selectedLabelList = ingredientLabelList
            
            headerLbl.text = "Ingredient Options"
        }
        else if category == "Meals"
        {
            selectedList = selectedMeals!
            selectedLabelList = mealLabelList
            
            headerLbl.text = "Meal Options"
        }
        
        likesTable.tableFooterView = UIView()
        likesTable.reloadData()
    }
    
    @objc func dismissKeyboard () {
        
        self.view.endEditing(true)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitOptions(_ sender: Any) {
        
        NotificationCenter.default.post(name: Notification.Name("updateFilter"), object: self.selectedList)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func next(_ sender: Any) {
        
//        submitBtn.isEnabled = false
//        self.submitBtn.alpha = 0.5
//
//        var paramString = "category=\(category!)&uid=\(appDelegate.userid!)"
//
//        for field in fields
//        {
//            let val = field.restorationIdentifier?.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
//
//            paramString = "\(paramString)&\(val!)=\(field.text!)"
//        }
//
//        print("vars: \(paramString)")
//
//        activityView.isHidden = false
//        activityView.startAnimating()
//
//        let urlString = "\(appDelegate.serverDestination!)addNutritionGoals.php"
//
//        print("urlString: \(urlString)")
//
//        let url = URL(string: urlString)
//        var request = URLRequest(url: url!)
//
//        request.httpMethod = "POST"
//
//        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
//
//        let session = URLSession.shared
//
//        session.dataTask(with: request) {data, response, err in
//
//            //print("Entered the completionHandler: \(response)")
//
//            //var err: NSError?
//
//            do {
//
//                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
//
//                print("goalsData: \(jsonResult)")
//
//                let dataDict : NSDictionary = jsonResult.object(forKey: "data") as! NSDictionary
//
//                //print("dataDict: \(dataDict)")
//
//                let uploadData : NSDictionary = dataDict.object(forKey: "goalsData") as! NSDictionary
//
//                if (uploadData != nil)
//                {
//                    let status = uploadData.object(forKey: "status") as? String
//
//                    if (status == "goals info saved")
//                    {
//                        DispatchQueue.main.sync(execute: {
//
//                            self.activityView.isHidden = true
//                            self.activityView.stopAnimating()
//
//                            self.submitBtn.isEnabled = true
//                            self.submitBtn.alpha = 1
//
//                            self.performSegue(withIdentifier: "login", sender: self)
//                        })
//                    }
//                    else
//                    {
//                        DispatchQueue.main.sync(execute: {
//
//                            self.activityView.isHidden = true
//                            self.activityView.stopAnimating()
//
//                            self.submitBtn.isEnabled = true
//                            self.submitBtn.alpha = 1
//
//                            self.showBasicAlert(string: status!)
//                        })
//                    }
//                }
//                else
//                {
//                    //data not returned
//                }
//            }
//            catch let err as NSError
//            {
//                print("error: \(err.description)")
//            }
//
//        }.resume()
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.selectedLabelList!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : GoalsTableViewCell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! GoalsTableViewCell
        
        let val = self.selectedLabelList![(indexPath as NSIndexPath).row]
        
        print("val: \(val)")
        
        cell.itemLbl?.text = val as? String
        
        if (selectedList?.contains(val))!
        {
            //cell.setSelected(true, animated: false)
            
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)

        }
        
        return cell
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        
        print("tf: \(textField.restorationIdentifier!) \(textField.text!)")
        
        //        let dict : NSDictionary = ["field" : textField.restorationIdentifier!, "val" : textField.text!]
        //
        //
        //        savedVals.add(dict)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = selectedLabelList![indexPath.row]
        
        if (!(selectedList?.contains(item))!)
        {
            selectedList?.add(item)
        }
        
        print("selectedList: \(selectedList)")
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        let item = selectedLabelList![indexPath.row]
        
        if (selectedList?.contains(item))!
        {
            selectedList?.remove(item)
        }
        
        print("selectedList: \(selectedList)")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        //        if textField.restorationIdentifier == "other" && textField.text != ""
        //        {
        //            cuisines.add(otherTxt.text!)
        //            otherTxt.text = ""
        //            cuisineCV.reloadData()
        //        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //        if segue.identifier == "AddIngredients"
        //        {
        //            let destination = segue.destination as! AddIngredients
        //            destination.category = category
        //        }
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
