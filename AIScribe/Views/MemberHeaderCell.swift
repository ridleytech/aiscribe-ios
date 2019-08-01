//
//  MemberHeaderCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 9/15/18.
//  Copyright © 2018 RT. All rights reserved.
//

import UIKit

class MemberHeaderCell: UITableViewCell {

    @IBOutlet weak var headerLbl: UILabel!
    @IBOutlet weak var leadingWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
