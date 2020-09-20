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
    @IBOutlet var googleIconView: UIImageView!
    @IBOutlet var githubIconView: UIImageView!
    
    func setView(name: String, avatarURL: URL?) {
        nameLabel.text = name
        avatarImageView.pin_updateWithProgress = true
        avatarImageView.pin_setImage(from: avatarURL)
        avatarImageView.layer.cornerRadius = 40
    }
    
    func setView(name: String, avatarFileName: String) {
        nameLabel.text = name
        avatarImageView.setImage(UIImage(named: avatarFileName)!)
    }
}
