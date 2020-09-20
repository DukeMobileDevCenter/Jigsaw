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
    /// A copy of the struct being previewed.
    var structToPreview: Any!
    /// The image view to show the game's placeholder image.
    @IBOutlet var imageView: UIImageView!
    /// The label to show the title of the game.
    @IBOutlet var titleLabel: UILabel!
    /// The label to show the detail text of the game.
    @IBOutlet var detailLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPreviewFromStruct(structToPreview!)
    }
    
    private func loadPreviewFromStruct(_ item: Any) {
        if let game = item as? Game {
            imageView.pin_setImage(from: game.backgroundImageURL)
            titleLabel.text = game.gameName
            detailLabel.text = game.detailText
        } else if let category = item as? GameCategory {
            imageView.setImage(category.backgroundImage)
            titleLabel.text = category.label
            detailLabel.text = category.detailText
        }
    }
}
