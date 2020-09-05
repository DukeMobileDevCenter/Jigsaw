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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressOnCell))
        longPressGestureRecognizer.minimumPressDuration = 0.05
        addGestureRecognizer(longPressGestureRecognizer)
        
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
    
    @objc
    func longPressOnCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let feedbackGenerator = UISelectionFeedbackGenerator()
        switch gestureRecognizer.state {
        case .began:
            feedbackGenerator.selectionChanged()
            UIView.animate(withDuration: 0.15) {
                self.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            }
        default:
            UIView.animate(withDuration: 0.15) {
                self.transform = .identity
            }
        }
    }
}
