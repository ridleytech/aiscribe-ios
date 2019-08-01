//
//  LikesTableViewCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/19/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class LikesTableViewCell: UITableViewCell {

    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var dislikeBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
