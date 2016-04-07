//
//  ListingCollectionViewCell.swift
//  SoLocal API
//
//  Created by Victor Jimenez Delgado on 2/1/16.
//  Copyright © 2016 Soleo. All rights reserved.
//

import UIKit

class ListingCollectionViewCell: UICollectionViewCell {
    
    //MARK: Fields
    @IBOutlet weak var ListingImage: UIImageView!
    
    @IBOutlet weak var ListingName: UILabel!
    
    @IBOutlet weak var ListingType: UILabel!
    
    @IBOutlet weak var ListingAddress: UILabel!
    
    @IBOutlet weak var ListingDistance: UILabel!
}
