//
//  DoorCollectionCell.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

class DoorCollectionCell: UICollectionViewCell {
    @IBOutlet var doorImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        doorImageView.layer.masksToBounds = true
        doorImageView.contentMode = .scaleAspectFill
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
    }
}
