//
//  ProfileHeaderView.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/12/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import PINRemoteImage

class ProfileHeaderView: UIView {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var avatarImageView: UIImageView!
    
    func setView(name: String, avatarURL: URL?) {
        nameLabel.text = name
        avatarImageView.pin_updateWithProgress = true
        avatarImageView.pin_setImage(from: avatarURL)
        avatarImageView.layer.cornerRadius = 40
    }
}
