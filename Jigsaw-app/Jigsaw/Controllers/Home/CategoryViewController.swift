//
//  CategoryCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {
    
    var category: GameCategory!
    var queueType: PlayersQueue!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var introductionLabel: UILabel!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        playButton.layer.cornerRadius = 15
        let selectedGame = GameStore.shared.getGames(for: category)[0]
        introductionLabel.text = selectedGame.introductionText
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
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

