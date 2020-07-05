//
//  MainTableViewCell.swift
//  Game Catalogue
//
//  Created by Miky Setiawan on 05/07/20.
//  Copyright © 2020 Miky Technology. All rights reserved.
//

import UIKit

class MainTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        NSLog("TESTING CLICK")
        // Configure the view for the selected state
    }
    
}
