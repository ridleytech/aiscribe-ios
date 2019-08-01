//
//  FeaturedRecipeView.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/20/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class FeaturedRecipeView: UIView {
    
    @IBOutlet weak var recipeIV: UIImageView!
    @IBOutlet weak var starsIV: UIImageView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    var isFavorite : Bool?
    
    @IBAction func manageFavorite(_ sender: Any) {
        
        if isFavorite == true
        {
            favoriteBtn.setBackgroundImage(UIImage.init(named: "addToFavorites"), for: .normal)
            isFavorite = false
        }
        else
        {
            favoriteBtn.setBackgroundImage(UIImage.init(named: "favorite"), for: .normal)
            isFavorite = true
        }
    }
    //    class func instanceFromNib() -> UIView {
//        return UINib(nibName: "FeaturedRecipeView", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! UIView
//    }
    
    class func createMyClassView() -> FeaturedRecipeView {
        let myClassNib = UINib(nibName: "FeaturedRecipeView", bundle: nil)
        return myClassNib.instantiate(withOwner: nil, options: nil)[0] as! FeaturedRecipeView
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
