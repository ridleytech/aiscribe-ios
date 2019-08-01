//
//  MenuTableViewCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 4/5/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class MenuTableViewCell: UITableViewCell {
    
    @IBOutlet weak var subheaderBottomPadding: NSLayoutConstraint!
    @IBOutlet weak var subheaderHeight: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
