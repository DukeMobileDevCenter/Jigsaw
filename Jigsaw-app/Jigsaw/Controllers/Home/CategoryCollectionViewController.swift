//
//  CategoryCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

class CategoryCollectionViewController: UICollectionViewController {
    /// The flow layout of the collection view.
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var category: GameCategory!
    var queueType: PlayersQueue!
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameStore.shared
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Coming back from a room does not refresh the page. Locked room still appears as locked.
        // Reload the data will make the cells look correct. #91
        collectionView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                let selectedGame = GameStore.shared.getGames(for: category)[selectedIndexPath.item]
                let destinationVC = segue.destination as! MatchingViewController
                destinationVC.queueType = queueType
                destinationVC.selectedGame = selectedGame
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension CategoryCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.bounds.inset(by: collectionView.safeAreaInsets).size
        let spacing: CGFloat = 10
        // First, try for 3 items in a row.
        var width = (collectionViewSize.width - 4 * spacing) / 3
        if width < 150 {
            // If device width too small, go for 2 in a row.
            width = (collectionViewSize.width - 3 * spacing) / 2
        }
        return CGSize(width: width, height: width)
    }
}

// MARK: - UIContextMenu

extension CategoryCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.item
        let game = GameStore.shared.getGames(for: category)[index]
        // Disable context menu if the game isn't unlocked yet.
        if !game.isEnabled { return nil }
        
        let identifier = "\(index)" as NSString
        let previewControllerProvider = { () -> UIViewController? in
            let storyboard = UIStoryboard(name: "PreviewDetailViewController", bundle: .main)
            let controller = storyboard.instantiateInitialViewController() as! PreviewDetailViewController
            controller.structToPreview = game
            return controller
        }
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: previewControllerProvider)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let identifier = configuration.identifier as? String,
            let item = Int(identifier) else { return }
        
        let cell = collectionView.cellForItem(at: IndexPath(item: item, section: 0))
        
        animator.addCompletion {
            self.performSegue(withIdentifier: "showGame", sender: cell)
        }
    }
}
