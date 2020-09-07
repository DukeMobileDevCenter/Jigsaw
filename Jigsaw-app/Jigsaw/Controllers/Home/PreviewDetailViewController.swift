//
//  PreviewDetailViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/7/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Down

class PreviewDetailViewController: UIViewController {
    /// A copy of the game being previewed.
    var game: Game!
    /// The image view to show the game's placeholder image.
    @IBOutlet var imageView: UIImageView!
    /// The label to show the title of the game.
    @IBOutlet var titleLabel: UILabel!
    /// The label to show the detail text of the game.
    @IBOutlet var detailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.pin_setImage(from: game.backgroundImageURL)
        titleLabel.text = game.gameName
        detailLabel.text = game.detailText
    }
}
