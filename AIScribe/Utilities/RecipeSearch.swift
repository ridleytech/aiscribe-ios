//
//  RecipeSearch.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/8/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class RecipeSearch: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var recipeCV: UICollectionView!
    
    var recipes = [NSDictionary]()
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        recipeCV.delegate = self
        recipeCV.dataSource = self
        
//        cuisines.add("Afgan")
//        cuisines.add("American")
//        cuisines.add("Argentinian")
//        cuisines.add("Belgian")
//        cuisines.add("Brazilian")
//        cuisines.add("Cajun")
                
        //debug()
        
        //recipeCV.reloadData()
    }
    
    func debug () {
        
        var dict : NSMutableDictionary = ["recipename" : "Pistachio-Crusted Chicken and Quinoa Salad", "category" : "","source" : "Hello Fresh","preptime" : "40 mins","calories" : "400","imagename" : "pistachio"]
        
        recipes.append(dict)
        
        dict = ["recipename" : "Mixed Mushroom Risotto", "category" : "1","source" : "Blue Apron","preptime" : "60 mins","calories" : "300","imagename" : "risotto"]
        
        recipes.append(dict)
        
        dict = ["recipename" : "Smoky Beluga Lentils", "category" : "2","source" : "Blue Apron","preptime" : "20 mins","calories" : "350","imagename" : "lentils"]
        
        recipes.append(dict)
        
        recipeCV.reloadData()
    }
    
    @IBAction func next(_ sender: Any) {}
    
    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate methods
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let kWhateverHeightYouWant = 190
        
        return CGSize.init(width: 600, height: CGFloat(kWhateverHeightYouWant))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return self.recipes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        //chanage cell width to 40% of screen
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? RecipesCollectionViewCell
        
        let dict = recipes[indexPath.row]
        
        cell?.frame.size = CGSize.init(width: recipeCV.frame.width * 0.5, height: 292) //Randall. check this
        
        cell?.recipeIV.image = UIImage.init(named: (dict.object(forKey: "imagename") as? String)!)
        cell?.headerLbl.text = dict.object(forKey: "recipename") as? String
        cell?.infoLbl.text = "\(dict.object(forKey: "preptime") as! String) • \(dict.object(forKey: "calories") as! String)"
        
        let attributedString = NSMutableAttributedString(string: "Source: \((dict.object(forKey: "source") as? String)!)", attributes: [
            .font: UIFont(name: "Avenir-Book", size: 13.0)!,
            .foregroundColor: appDelegate.crGray
            ])
        attributedString.addAttribute(.font, value: UIFont(name: "Avenir-Heavy", size: 13.0)!, range: NSRange(location: 0, length: 7))
        
        cell?.sourceLbl.attributedText = attributedString
        
        
//        if selectedCuisines.contains(string)
//        {
//            cell?.cuisineLbl.backgroundColor = appDelegate.crLightBlue
//            cell?.cuisineLbl.textColor = UIColor.white
//        }
//        else
//        {
//            cell?.cuisineLbl.backgroundColor = UIColor.white
//            cell?.cuisineLbl.textColor = appDelegate.crLightBlue
//        }
        
        
        //cell?.statusLbl.isHidden = true
        
        return cell!
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let recipe = recipes[indexPath.row]
        
        print("recipe: \(recipe)")
        
//        if selectedCuisines.contains(cuisine)
//        {
//            selectedCuisines.remove(cuisine)
//        }
//        else
//        {
//            selectedCuisines.add(cuisine)
//        }
        
        //print("selectedCuisines: \(selectedCuisines)")
        
        recipeCV.reloadData()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
