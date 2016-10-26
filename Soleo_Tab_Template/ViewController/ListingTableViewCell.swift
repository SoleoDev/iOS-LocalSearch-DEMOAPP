//
//  ListingTableViewCell.swift
//  SoLocal API
//
//  Created by Victor Jimenez on 2/12/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit

class ListingTableViewCell: UITableViewCell {
    
    //MARK: Fields
    @IBOutlet weak var ListingImage: UIImageView!
    
    @IBOutlet weak var ListingName: UILabel!

    @IBOutlet weak var ListinType: UILabel!
    
    @IBOutlet weak var ListingDistance: UILabel!
    
    @IBOutlet weak var ListingAddress: UILabel!
    
    @IBOutlet weak var ListingCategory: UILabel!

}
