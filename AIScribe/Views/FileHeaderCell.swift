//
//  FileHeaderCell.swift
//  AIScribe
//
//  Created by Randall Ridley on 5/27/19.
//  Copyright © 2019 RT. All rights reserved.
//

import UIKit

class FileHeaderCell: UITableViewCell {
    
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
