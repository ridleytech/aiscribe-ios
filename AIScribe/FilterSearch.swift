//
//  FilterSearch.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/8/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class FilterSearch: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource{
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBOutlet weak var dietFilterView: UIView!
    
    var diets  = [NSDictionary]()
    var selectedDiets = NSMutableArray()
    
    var meals  = [NSDictionary]()
    var selectedMeals = NSMutableArray()
    
    var selectedCuisines = NSMutableArray()
    var selectedIngredients = NSMutableArray()
    var currentItemArray = NSMutableArray()
    
    var ingredients = [NSDictionary]()
    var cuisines = [NSDictionary]()
    
    @IBOutlet weak var cuisineCV: UICollectionView!
    @IBOutlet weak var mealsCV: UICollectionView!
    
    var selectedCategory : String?
    
    @IBOutlet weak var afghanBtn: UIButton!
    @IBOutlet weak var americanBtn: UIButton!
    @IBOutlet weak var argentinianBtn: UIButton!
    
    @IBOutlet weak var vegBtn: UIButton!
    @IBOutlet weak var chickenBtn: UIButton!
    @IBOutlet weak var pastaBtn: UIButton!
    
    var cuisineButtons = [UIButton]()
    var ingredientButtons = [UIButton]()
    
    @IBOutlet weak var dietHeight: NSLayoutConstraint!
    
    @IBOutlet weak var dietViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var cuisineTable: UITableView!
    
    @IBOutlet weak var ingredientTable: UITableView!
    @IBOutlet weak var cuisineHeight: NSLayoutConstraint!
    
    @IBOutlet weak var ingredientHeight: NSLayoutConstraint!
    
    
    @IBOutlet weak var sv: UIScrollView!
    
    @IBOutlet weak var svContentView: UIView!
    @IBOutlet weak var resultsLbl: UILabel!
    @IBOutlet weak var resultsView: UIView!
    @IBOutlet weak var resultsBtn: UIButton!
    
    var resultsCount : Int?
    
    // MARK: - viewDidLoad
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
//        cuisineButtons = [afghanBtn,americanBtn,argentinianBtn]
//        ingredientButtons = [vegBtn,chickenBtn,pastaBtn]
        
        cuisineCV.delegate = self
        cuisineCV.dataSource = self
        
        mealsCV.delegate = self
        mealsCV.dataSource = self

        cuisineTable.delegate = self
        cuisineTable.dataSource = self
        
//        ingredientTable.delegate = self
//        ingredientTable.dataSource = self
        
        cuisineTable.tableFooterView = UIView()
        //ingredientTable.tableFooterView = UIView()
        
        cuisineTable.separatorStyle = .none
        //ingredientTable.separatorStyle = .none
        
        resultsView.isHidden = true
        resultsLbl.isHidden = true
        resultsBtn.isHidden = true
        
        resultsCount = selectedCuisines.count + selectedIngredients.count + selectedMeals.count + selectedDiets.count
        
        if resultsCount! > 0
        {
            resultsLbl.text = "\(resultsCount!) results"
            resultsView.isHidden = false
            resultsLbl.isHidden = false
            resultsBtn.isHidden = false
        }
        
        //debug()
        
        //populateFields()
        
        getCuisines()
        getMeals()
        //getDiets()
        getAllConcerns()
                
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateFilterNotification),
            name: NSNotification.Name(rawValue: "updateFilter"),
            object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
//        sv.contentSize = CGSize.init(width: sv.frame.width, height: 1500)
//        svContentView.setNeedsLayout()
        
        //svContentView.updateConstraints()
        //svContentView.needsUpdateConstraints()
        //svContentView.setNeedsLayout()
        
        //svContentView.frame = CGRect.init(x:0, y:0, width: sv.frame.width, height: 2500)
        //svContentView.setNeedsDisplay()
    }
    
    func populateFields () {
        
        for btn in cuisineButtons
        {
            if selectedCuisines.contains(btn.restorationIdentifier!)
            {
                //btn.backgroundColor = .red
                btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            }
            else
            {
                //btn.backgroundColor = .gray
                btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            }
        }
       
        for btn in ingredientButtons
        {
            if selectedIngredients.contains(btn.restorationIdentifier!)
            {
                btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            //btn.backgroundColor = .red
            }
            else
            {
                btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
                //btn.backgroundColor = .gray
            }
        }
    }
    
    // MARK: - Notifications
    
    @objc func updateFilterNotification (notification: NSNotification) {
        
        print("port: \(notification.object)")
        
        if selectedCategory == "Diets"
        {
            selectedDiets = notification.object as! NSMutableArray
            
            cuisineCV.reloadData()
        }
        else if selectedCategory == "Cuisines"
        {
            selectedCuisines = notification.object as! NSMutableArray
            
            for btn in cuisineButtons
            {
                if selectedCuisines.contains(btn.restorationIdentifier!)
                {
                    btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
                    //btn.setBackgroundImage(UIImage.init(named: "<#T##String#>"), for: .normal)
                }
                else
                {
                    //btn.backgroundColor = .gray
                    btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
                }
            }
        }
        else if selectedCategory == "Ingredients"
        {
            selectedIngredients = notification.object as! NSMutableArray
            
            for btn in ingredientButtons
            {
                if selectedIngredients.contains(btn.restorationIdentifier!)
                {
                    //btn.backgroundColor = .red
                    btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
                }
                else
                {
                    //btn.backgroundColor = .gray
                    btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
                }
            }
        }
        else if selectedCategory == "Meals"
        {
            selectedMeals = notification.object as! NSMutableArray
            
            mealsCV.reloadData()
        }
    }
    
    // MARK: - Actions
    
    @IBAction func clearResults(_ sender: Any) {
        
        resultsLbl.text = ""
        resultsView.isHidden = true
        resultsLbl.isHidden = true
        resultsBtn.isHidden = true
        
        selectedCuisines.removeAllObjects()
        selectedIngredients.removeAllObjects()
        selectedMeals.removeAllObjects()
        selectedDiets.removeAllObjects()
        
        cuisineTable.reloadData()
        cuisineCV.reloadData()
        mealsCV.reloadData()
    }
    
    @IBAction func selectMealOption(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        if selectedMeals.contains(btn.restorationIdentifier!)
        {
            btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            //btn.backgroundColor = .gray
            selectedMeals.remove(btn.restorationIdentifier!)
        }
        else
        {
            btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            //btn.backgroundColor = .red
            selectedMeals.add(btn.restorationIdentifier!)
        }
    }
    
    @IBAction func selectCuisineOption(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        if selectedCuisines.contains(btn.restorationIdentifier!)
        {
            //btn.backgroundColor = .gray
            btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            selectedCuisines.remove(btn.restorationIdentifier!)
        }
        else
        {
            btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            //btn.backgroundColor = .red
            selectedCuisines.add(btn.restorationIdentifier!)
        }
    }
    
    @IBAction func selectIngredientOption(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        if selectedIngredients.contains(btn.restorationIdentifier!)
        {
            btn.setBackgroundImage(UIImage.init(named: "unselected"), for: .normal)
            //btn.backgroundColor = .gray
            selectedIngredients.remove(btn.restorationIdentifier!)
        }
        else
        {
            btn.setBackgroundImage(UIImage.init(named: "selected"), for: .normal)
            //btn.backgroundColor = .red
            selectedIngredients.add(btn.restorationIdentifier!)
        }
    }
    
    @IBAction func viewMoreCuisine(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        selectedCategory = btn.restorationIdentifier!
        
        performSegue(withIdentifier: "ShowMore", sender: nil)
    }
    
    @IBAction func viewMoreIngredients(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        selectedCategory = btn.restorationIdentifier!
        
        performSegue(withIdentifier: "ShowMore", sender: nil)
    }
    
    @IBAction func viewMoreDiet(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        selectedCategory = btn.restorationIdentifier!
        
        if dietHeight.constant == 800
        {
            dietHeight.constant = 170
            btn.setTitle("+ MORE DIET", for: .normal)
        }
        else
        {
            dietHeight.constant = 800
            btn.setTitle("- LESS DIET", for: .normal)
        }
        
        //performSegue(withIdentifier: "ShowMore", sender: nil)
    }
    
    @IBAction func moreCuisine(_ sender: Any) {
        
        let btn = sender as! UIButton
        
        let newHeight = CGFloat(cuisines.count * 30)
        
        if cuisineHeight.constant == newHeight
        {
            cuisineHeight.constant = 170
            btn.setTitle("+ MORE CUISINE", for: .normal)
        }
        else
        {
            cuisineHeight.constant = newHeight
            btn.setTitle("- LESS CUISINE", for: .normal)
        }
    }
    
    @IBAction func moreIngredients(_ sender: Any) {
        
        ingredientHeight.constant = 1000
    }
    
    @IBAction func applyFilters(_ sender: Any) {
        
        let dict : NSDictionary = ["selectedMeals" : selectedMeals, "selectedIngredients" : selectedIngredients, "selectedCuisines" : selectedCuisines, "selectedDiets" : selectedDiets]
        
        NotificationCenter.default.post(name: Notification.Name("applyFilters"), object: dict)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Collectionview
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let kWhateverHeightYouWant = 190
        
        return CGSize.init(width: 600, height: CGFloat(kWhateverHeightYouWant))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.restorationIdentifier == "diet"
        {
            return self.diets.count
        }
        else
        {
            return self.meals.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CuisinesCollectionviewCell
        
        var theDict : NSDictionary?
        
        var id = ""
        
        if collectionView.restorationIdentifier == "diet"
        {
            theDict = self.diets[indexPath.row]
            id = theDict?.object(forKey: "concernid") as! String
        }
        else
        {
            theDict = self.meals[indexPath.row]
            id = theDict?.object(forKey: "mealid") as! String
        }
        
        let string = theDict?.object(forKey: "name") as! String

        let img = theDict?.object(forKey: "image") as! UIImage
        let img2 = theDict?.object(forKey: "image2") as! UIImage
        
        cell?.cuisineLbl.text = string
        cell?.iconIV.image = img
        
        if collectionView.restorationIdentifier == "diet"
        {
            if selectedDiets.contains(id)
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
        }
        else
        {
            if selectedMeals.contains(id)
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
        }
        
        cell?.layer.borderWidth = 1.0
        cell?.layer.borderColor = appDelegate.crLightBlue.cgColor
        cell?.layer.cornerRadius = 4.0

        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.restorationIdentifier == "diet"
        {
            let dietDict = diets[indexPath.row] as NSDictionary
            
            let dietid = dietDict.object(forKey: "concernid") as! String
            
            print("dietid: \(dietid)")
            
            if selectedDiets.contains(dietid)
            {
                selectedDiets.remove(dietid)
            }
            else
            {
                selectedDiets.add(dietid)
            }
            
            print("selectedDiets: \(selectedDiets)")
            
            cuisineCV.reloadData()
        }
        else
        {
            let mealDict = meals[indexPath.row] as NSDictionary
            
            let mealid = mealDict.object(forKey: "mealid") as! String
            
            print("meal: \(mealid)")
            
            if selectedMeals.contains(mealid)
            {
                selectedMeals.remove(mealid)
            }
            else
            {
                selectedMeals.add(mealid)
            }
            
            print("selectedMeals: \(selectedMeals)")
            
            mealsCV.reloadData()
        }
    }
    
    // MARK: - Data
    
    func debug () {
        
        diets.append( ["name" : "Diabetic", "image" : UIImage.init(named: "noSugarBlue")!, "image2" : UIImage.init(named: "noSugarWhite")!])
        diets.append( ["name" : "Dairy Allergy", "image" : UIImage.init(named: "dairyAllergyBlue")!, "image2" : UIImage.init(named: "dairyAllergyWhite")!])
        diets.append( ["name" : "Egg Allergy", "image" : UIImage.init(named: "eggAllergyBlue")!, "image2" : UIImage.init(named: "eggAllergyWhite")!])
        diets.append( ["name" : "Fish Allergy", "image" : UIImage.init(named: "fishAllergyBlue")!, "image2" : UIImage.init(named: "fishAllergyWhite")!])
        diets.append( ["name" : "Flexitarian", "image" : UIImage.init(named: "flexitarianBlue")!, "image2" : UIImage.init(named: "flexitarianWhite")!])
        diets.append( ["name" : "Gluten Intolerance", "image" : UIImage.init(named: "glutenIntoleranceBlue")!, "image2" : UIImage.init(named: "glutenIntoleranceWhite")!])
        
        meals.append( ["name" : "Breakfast", "image" : UIImage.init(named: "noSugarBlue")!, "image2" : UIImage.init(named: "noSugarWhite")!])
        meals.append( ["name" : "Lunch", "image" : UIImage.init(named: "dairyAllergyBlue")!, "image2" : UIImage.init(named: "dairyAllergyWhite")!])
        meals.append( ["name" : "Snack", "image" : UIImage.init(named: "eggAllergyBlue")!, "image2" : UIImage.init(named: "eggAllergyWhite")!])
        meals.append( ["name" : "Dinner", "image" : UIImage.init(named: "fishAllergyBlue")!, "image2" : UIImage.init(named: "fishAllergyWhite")!])
        meals.append( ["name" : "Dessert", "image" : UIImage.init(named: "flexitarianBlue")!, "image2" : UIImage.init(named: "flexitarianWhite")!])
        
        cuisines.append( ["name" : "Afgan", "id" : "1"])
        ingredients.append( ["name" : "Vegetables", "id" : "1"])
        
//        diets.append( ["name" : "Halal", "image" : UIImage.init(named: "halalBlue")!, "image2" : UIImage.init(named: "halalWhite")!])
//        diets.append( ["name" : "Heart Healthy", "image" : UIImage.init(named: "heartHealthyBlue")!, "image2" : UIImage.init(named: "heartHealthyWhite")!])
//        diets.append( ["name" : "Keto", "image" : UIImage.init(named: "ketoBlue")!, "image2" : UIImage.init(named: "ketoWhite")!])
//        diets.append( ["name" : "Kosher", "image" : UIImage.init(named: "kosherBlue")!, "image2" : UIImage.init(named: "kosherWhite")!])
//        diets.append( ["name" : "Lacto Vegitarian", "image" : UIImage.init(named: "lactoVegetarianBlue")!, "image2" : UIImage.init(named: "lactoVegetarianWhite")!])
//        diets.append( ["name" : "Lactose Intolerant", "image" : UIImage.init(named: "lactoseIntoleranceBlue")!, "image2" : UIImage.init(named: "lactoseIntoleranceWhite")!])
//        diets.append( ["name" : "Low Carb", "image" : UIImage.init(named: "lowCarbBlue")!, "image2" : UIImage.init(named: "lowCarbWhite")!])
//        diets.append( ["name" : "Low Fat", "image" : UIImage.init(named: "lowFatBlue")!, "image2" : UIImage.init(named: "lowFatWhite")!])
//        diets.append( ["name" : "Low Sodium", "image" : UIImage.init(named: "lowSodiumBlue")!, "image2" : UIImage.init(named: "lowSodiumWhite")!])
//        diets.append( ["name" : "Low Sugar", "image" : UIImage.init(named: "lowSugarBlue")!, "image2" : UIImage.init(named: "lowSugarWhite")!])
//        diets.append( ["name" : "Ovo Vegetarian", "image" : UIImage.init(named: "ovoVegetarianBlue")!, "image2" : UIImage.init(named: "ovoVegetarianWhite")!])
//        diets.append( ["name" : "Paleo", "image" : UIImage.init(named: "paleoBlue")!, "image2" : UIImage.init(named: "paleoWhite")!])
//        diets.append( ["name" : "Peanut Allergy", "image" : UIImage.init(named: "peanutAllergyBlue")!, "image2" : UIImage.init(named: "peanutAllergyWhite")!])
//        diets.append( ["name" : "Pescetarian", "image" : UIImage.init(named: "pescetarianBlue")!, "image2" : UIImage.init(named: "pescetarianWhite")!])
//        diets.append( ["name" : "Shellfish Allergy", "image" : UIImage.init(named: "shellfishAllergyBlue")!, "image2" : UIImage.init(named: "shellfishAllergyWhite")!])
//        diets.append( ["name" : "Soy Allergy", "image" : UIImage.init(named: "soyAllergyBlue")!, "image2" : UIImage.init(named: "soyAllergyWhite")!])
//        diets.append( ["name" : "Vegan", "image" : UIImage.init(named: "veganBlue")!, "image2" : UIImage.init(named: "veganWhite")!])
//        diets.append( ["name" : "Vegetarian", "image" : UIImage.init(named: "vegetarianBlue")!, "image2" : UIImage.init(named: "vegetarianWhite")!])
//        diets.append( ["name" : "Wheat Allergy", "image" : UIImage.init(named: "wheatAllergyBlue")!, "image2" : UIImage.init(named: "wheatAllergyWhite")!])
        
        cuisineCV.reloadData()
        mealsCV.reloadData()
        ingredientTable.reloadData()
        cuisineTable.reloadData()
    }
    
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
                            
                            self.diets.append( ["name" : name, "image" : UIImage.init(named: image as! String)!, "image2" : UIImage.init(named: image2 as! String)!,"concernid": concernid])
                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if hasData == true
                            {
                                self.cuisineCV.reloadData()
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
    
    func getDiets () {
        
        diets.append( ["name" : "Diabetic", "image" : UIImage.init(named: "noSugarBlue")!, "image2" : UIImage.init(named: "noSugarWhite")!,"concernid": "1"])
        diets.append( ["name" : "Dairy Allergy", "image" : UIImage.init(named: "dairyAllergyBlue")!, "image2" : UIImage.init(named: "dairyAllergyWhite")!,"concernid": "2"])
        diets.append( ["name" : "Egg Allergy", "image" : UIImage.init(named: "eggAllergyBlue")!, "image2" : UIImage.init(named: "eggAllergyWhite")!,"concernid": "3"])
        diets.append( ["name" : "Fish Allergy", "image" : UIImage.init(named: "fishAllergyBlue")!, "image2" : UIImage.init(named: "fishAllergyWhite")!,"concernid": "4"])
        diets.append( ["name" : "Flexitarian", "image" : UIImage.init(named: "flexitarianBlue")!, "image2" : UIImage.init(named: "flexitarianWhite")!,"concernid": "5"])
        diets.append( ["name" : "Gluten Intolerance", "image" : UIImage.init(named: "glutenIntoleranceBlue")!, "image2" : UIImage.init(named: "glutenIntoleranceWhite")!,"concernid": "6"])
        diets.append( ["name" : "Halal", "image" : UIImage.init(named: "halalBlue")!, "image2" : UIImage.init(named: "halalWhite")!,"concernid": "7"])
        diets.append( ["name" : "Heart Healthy", "image" : UIImage.init(named: "heartHealthyBlue")!, "image2" : UIImage.init(named: "heartHealthyWhite")!,"concernid": "8"])
        diets.append( ["name" : "Keto", "image" : UIImage.init(named: "ketoBlue")!, "image2" : UIImage.init(named: "ketoWhite")!,"concernid": "9"])
        diets.append( ["name" : "Kosher", "image" : UIImage.init(named: "kosherBlue")!, "image2" : UIImage.init(named: "kosherWhite")!,"concernid": "10"])
        diets.append( ["name" : "Lacto Vegitarian", "image" : UIImage.init(named: "lactoVegetarianBlue")!, "image2" : UIImage.init(named: "lactoVegetarianWhite")!,"concernid": "11"])
        diets.append( ["name" : "Lactose Intolerant", "image" : UIImage.init(named: "lactoseIntoleranceBlue")!, "image2" : UIImage.init(named: "lactoseIntoleranceWhite")!,"concernid": "12"])
        diets.append( ["name" : "Low Carb", "image" : UIImage.init(named: "lowCarbBlue")!, "image2" : UIImage.init(named: "lowCarbWhite")!,"concernid": "13"])
        diets.append( ["name" : "Low Fat", "image" : UIImage.init(named: "lowFatBlue")!, "image2" : UIImage.init(named: "lowFatWhite")!,"concernid": "14"])
        diets.append( ["name" : "Low Sodium", "image" : UIImage.init(named: "lowSodiumBlue")!, "image2" : UIImage.init(named: "lowSodiumWhite")!,"concernid": "15"])
        diets.append( ["name" : "Low Sugar", "image" : UIImage.init(named: "lowSugarBlue")!, "image2" : UIImage.init(named: "lowSugarWhite")!,"concernid": "16"])
        diets.append( ["name" : "Ovo Vegetarian", "image" : UIImage.init(named: "ovoVegetarianBlue")!, "image2" : UIImage.init(named: "ovoVegetarianWhite")!,"concernid": "17"])
        diets.append( ["name" : "Paleo", "image" : UIImage.init(named: "paleoBlue")!, "image2" : UIImage.init(named: "paleoWhite")!,"concernid": ""])
        diets.append( ["name" : "Peanut Allergy", "image" : UIImage.init(named: "peanutAllergyBlue")!, "image2" : UIImage.init(named: "peanutAllergyWhite")!,"concernid": "18"])
        diets.append( ["name" : "Pescetarian", "image" : UIImage.init(named: "pescetarianBlue")!, "image2" : UIImage.init(named: "pescetarianWhite")!,"concernid": "19"])
        diets.append( ["name" : "Shellfish Allergy", "image" : UIImage.init(named: "shellfishAllergyBlue")!, "image2" : UIImage.init(named: "shellfishAllergyWhite")!,"concernid": "20"])
        diets.append( ["name" : "Soy Allergy", "image" : UIImage.init(named: "soyAllergyBlue")!, "image2" : UIImage.init(named: "soyAllergyWhite")!,"concernid": "21"])
        diets.append( ["name" : "Vegan", "image" : UIImage.init(named: "veganBlue")!, "image2" : UIImage.init(named: "veganWhite")!,"concernid": ""])
        diets.append( ["name" : "Vegetarian", "image" : UIImage.init(named: "vegetarianBlue")!, "image2" : UIImage.init(named: "vegetarianWhite")!,"concernid": "22"])
        diets.append( ["name" : "Wheat Allergy", "image" : UIImage.init(named: "wheatAllergyBlue")!, "image2" : UIImage.init(named: "wheatAllergyWhite")!,"concernid": "23"])
        diets.append( ["name" : "Other", "image" : UIImage.init(named: "add")!, "image2" : UIImage.init(named: "add")!,"concernid": "24"])
        
        cuisineCV.reloadData()
    }
    
    func getMeals() {
        
        meals.append( ["name" : "Breakfast", "image" : UIImage.init(named: "noSugarBlue")!, "image2" : UIImage.init(named: "noSugarWhite")!,"mealid" : "1"])
        meals.append( ["name" : "Lunch", "image" : UIImage.init(named: "dairyAllergyBlue")!, "image2" : UIImage.init(named: "dairyAllergyWhite")!,"mealid" : "2"])
        meals.append( ["name" : "Snack", "image" : UIImage.init(named: "eggAllergyBlue")!, "image2" : UIImage.init(named: "eggAllergyWhite")!,"mealid" : "3"])
        meals.append( ["name" : "Dinner", "image" : UIImage.init(named: "fishAllergyBlue")!, "image2" : UIImage.init(named: "fishAllergyWhite")!,"mealid" : "4"])
        meals.append( ["name" : "Dessert", "image" : UIImage.init(named: "flexitarianBlue")!, "image2" : UIImage.init(named: "flexitarianWhite")!,"mealid" : "5"])
        
        mealsCV.reloadData()
    }
    
    // MARK: - Webservice
    
    func getCuisines() {
        
        print("getMyCuisines")
        
        let dataString = "cuisineData"
        
        let urlString = "\(appDelegate.serverDestination!)getCuisines.php"
        
        let url = URL(string: urlString)
        
        var request = URLRequest(url: url!)
        
        request.httpMethod = "POST"
        
        let paramString = "register=true&devStatus=\(appDelegate.devStage!)&mobile=true"
        
        print("urlString: \(urlString)")
        print("paramString: \(paramString)")
        
        request.httpBody = paramString.data(using: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
        
        let session = URLSession.shared
        
        session.dataTask(with: request) {data, response, err in
            
            do {
                
                let jsonResult = try JSONSerialization.jsonObject(with: data!, options: []) as! NSDictionary
                
                print("cuisines jsonResult: \(jsonResult)")
                
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
                    let uploadData : NSMutableArray = (dataDict[dataString]! as! NSArray).mutableCopy() as! NSMutableArray
                    
                     self.cuisines = uploadData as! [NSDictionary]
                    
                    var hasData = false
                    
                    if (self.cuisines.count > 0)
                    {
                        hasData = true
                        
//                        for dict in recipes1
//                        {
//                            let dict2 = dict.mutableCopy() as! NSMutableDictionary
//
//                            self.cuisines.add(dict2)
//                        }
                        
                        DispatchQueue.main.sync(execute: {
                            
                            if hasData == true
                            {
                                self.cuisineTable.reloadData()
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
    
    // MARK: Tableview
    
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
        
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.restorationIdentifier == "ingredients"
        {
            return self.ingredients.count
        }
        else
        {
            return self.cuisines.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell")! as! FriendRequestCell
        
        cell.selectionStyle = .none
        
        
        if tableView.restorationIdentifier == "ingredients"
        {
            let dict = ingredients[(indexPath as NSIndexPath).row]
            
            let symbol = dict.object(forKey: "name") as! String
            
            cell.nameLbl!.text = symbol
            
            if selectedIngredients.contains(dict)
            {
                cell.friendIV.image = UIImage.init(named: "selected")
            }
            else
            {
                cell.friendIV.image = UIImage.init(named: "unselected")
            }
        }
        else
        {
            let dict = cuisines[(indexPath as NSIndexPath).row]
            
            let symbol = dict.object(forKey: "cuisinename") as! String
            let cuisineid = dict.object(forKey: "cuisineid") as! String
            
            cell.nameLbl!.text = symbol
            
            if selectedCuisines.contains(cuisineid)
            {
                cell.friendIV.image = UIImage.init(named: "selected")
            }
            else
            {
                cell.friendIV.image = UIImage.init(named: "unselected")
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView.restorationIdentifier == "ingredients"
        {
            let dict = ingredients[(indexPath as NSIndexPath).row]
            
            if selectedIngredients.contains(dict)
            {
                selectedIngredients.remove(dict)
            }
            else
            {
                selectedIngredients.add(dict)
            }
            
            ingredientTable.reloadData()
        }
        else
        {
            let dict = cuisines[(indexPath as NSIndexPath).row]
            
            let cuisineid = dict.object(forKey: "cuisineid") as! String
            
            if selectedCuisines.contains(cuisineid)
            {
                selectedCuisines.remove(cuisineid)
            }
            else
            {
                selectedCuisines.add(cuisineid)
            }
            
            print("selectedCuisines: \(selectedCuisines)")
            
            cuisineTable.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ShowMore"
        {
            let destination = segue.destination as! ShowMoreFilterOptions
            
            destination.category = selectedCategory
            destination.selectedCuisines = selectedCuisines
            destination.selectedIngredients = selectedIngredients
            destination.selectedMeals = selectedMeals
            destination.selectedDiets = selectedDiets
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
