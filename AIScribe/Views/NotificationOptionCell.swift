//
//  NotificationOptionCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 12/9/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class NotificationOptionCell: UITableViewCell {
    
    @IBOutlet weak var optionLbl: UILabel!
    @IBOutlet weak var optionIV: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
