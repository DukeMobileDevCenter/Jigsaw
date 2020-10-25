//
//  GameCollectionCell.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/10/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

class GameCollectionCell: UICollectionViewCell {
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var iconBackgroundView: UIView!
    @IBOutlet var iconImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        iconBackgroundView.layer.cornerRadius = 25
        iconBackgroundView.layer.masksToBounds = true
        backgroundImageView.layer.masksToBounds = true
        backgroundImageView.contentMode = .scaleAspectFill
        contentView.layer.cornerRadius = 8
        contentView.clipsToBounds = true
        
        layer.shadowOffset = .zero
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 8
        layer.shadowOpacity = 0.6
        layer.masksToBounds = false
    }
}
