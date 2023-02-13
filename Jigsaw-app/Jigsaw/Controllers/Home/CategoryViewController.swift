//
//  CategoryCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Down

class CategoryViewController: UIViewController {
    var category: GameCategory!
    var queueType: PlayersQueue!
    private var darkMode: Bool = false
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var introductionLabel: UITextView!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        playButton.layer.cornerRadius = 15
        darkMode = self.traitCollection.userInterfaceStyle == .dark
        // normal games
        if let selectedGame = GameStore.shared.getGames(for: category).first {
            let attributedText = try? Down(markdownString: selectedGame.introductionText).toAttributedString(.default, stylesheet: darkMode ? AppConstants.darkModeStylesheet : AppConstants.simpleStylesheet)
            introductionLabel.attributedText = attributedText
        }
        // demo game
        else {
            introductionLabel.text = "Demo"
        }
            
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            let selectedGame = GameStore.shared.getGames(for: category)[0]
            let destinationVC = segue.destination as! MatchingViewController
            destinationVC.queueType = queueType
            destinationVC.selectedGame = selectedGame
        case "showDemo"?:
            print("[debug]")
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
