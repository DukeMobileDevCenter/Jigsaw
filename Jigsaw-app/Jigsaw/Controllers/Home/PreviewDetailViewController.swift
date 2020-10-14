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
    
    private let stylesheet =
    """
    body { font: -apple-system-body }
    h1 { font: -apple-system-title1 }
    h2 { font: -apple-system-title2 }
    h3 { font: -apple-system-title3 }
    h4, h5, h6 { font: -apple-system-headline }
    """
    
    private func loadPreviewFromStruct(_ item: Any) {
        if let game = item as? Game {
            imageView.pin_setImage(from: game.backgroundImageURL)
            titleLabel.text = game.gameName
            detailLabel.attributedText = try? Down(markdownString: game.detailText).toAttributedString(.default, stylesheet: stylesheet)
        } else if let category = item as? GameCategory {
            imageView.setImage(category.backgroundImage)
            titleLabel.text = category.label
            detailLabel.text = category.detailText
        }
    }
}
