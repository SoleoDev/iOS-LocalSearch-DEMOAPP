//
//  RecentTableViewCell.swift
//  SoLocal API
//
//  Created by Victor Jimenez Delgado on 2/1/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    //MARK: Fields
    
    @IBOutlet weak var Search_name: UITextField!
    
    @IBOutlet weak var ValidTime: UILabel!
    
    @IBOutlet weak var FavButton: UIImageView!

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
