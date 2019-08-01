//
//  GoalsTableViewCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/19/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class GoalsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var itemLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var tf: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
