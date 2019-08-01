//
//  RecipesCollectionViewCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 6/8/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class RecipesCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var recipeIV: UIImageView!
    @IBOutlet weak var starsIV: UIImageView!
    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var sourceLbl: UILabel!
    @IBOutlet weak var favoriteBtn: UIButton!
    var isFavorite : Bool?
    
    @IBOutlet weak var videoBtn: UIButton!
    var videoURL: String!
    
}
