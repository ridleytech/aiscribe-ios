//
//  GroceryRecipeListCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 8/22/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class GroceryRecipeListCell: UITableViewCell {
    
    @IBOutlet weak var ingredientsLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var recipeIV: UIImageView!
    //@IBOutlet weak var selectBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
