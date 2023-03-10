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
    var isDemo = false
    private var darkMode: Bool = false
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var introductionLabel: UITextView!
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if isDemo {
            performSegue(withIdentifier: "showDemoGame", sender: sender)
        } else {
            performSegue(withIdentifier: "showGame", sender: sender)
        }
    }

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
            let attributedText = try? Down(markdownString: Strings.DemoGame.instruction).toAttributedString(.default, stylesheet: darkMode ? AppConstants.darkModeStylesheet : AppConstants.simpleStylesheet)
            introductionLabel.attributedText = attributedText
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
        case "showDemoGame"?:
            let destinationVC = segue.destination as! MatchingViewController
            destinationVC.isDemo = true
            // Using immigration Game for Demo
            destinationVC.selectedGame = GameStore.shared.getGames(for: .immigration)[0]
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}
