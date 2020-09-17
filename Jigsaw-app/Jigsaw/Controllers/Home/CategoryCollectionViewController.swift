//
//  CategoryCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import ProgressHUD

class CategoryCollectionViewController: UICollectionViewController {
    /// The flow layout of the collection view.
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    
    var category: GameCategory!
    var queueType: PlayersQueue!
    
    private func configureRefreshControl() {
        // Add the refresh control to UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadGames), for: .valueChanged)
    }
    
    @objc
    private func loadGames() {
        // Asynchronously load the games from Firebase.
        ProgressHUD.show()
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let games):
                os_log(.info, "games count = %d", games.count)
                // Update collection view UI here.
            case .failure(let error):
                os_log(.error, "Error: loading games from remote")
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadSections(IndexSet(integer: 0))
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameStore.shared
        
        // Configure pull to refresh.
        configureRefreshControl()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                let selectedGame = GameStore.shared.getGames(for: category)[selectedIndexPath.item]
                let destinationVC = segue.destination as! MatchingViewController
                destinationVC.games = GameStore.shared.allGames
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
        let identifier = "\(index)" as NSString
        let previewControllerProvider = { () -> UIViewController? in
            let storyboard = UIStoryboard(name: "PreviewDetailViewController", bundle: .main)
            let controller = storyboard.instantiateInitialViewController() as! PreviewDetailViewController
            controller.structToPreview = game
            return controller
        }
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: previewControllerProvider) { _ in
            let previewAction = UIAction(title: "Mark as Played", image: UIImage(systemName: "checkmark.square")) { _ in
                self.presentAlert(title: "More to add here", message: "Can add a mark as played or favorite feature.")
            }
            let shareAction = UIAction(title: "Share", image: UIImage(systemName: "square.and.arrow.up")) { _ in
                self.presentAlert(title: "More to add here", message: "\(game.gameName) selected. Can add a share game with friend feature.")
            }
            return UIMenu(title: "", image: nil, children: [previewAction, shareAction])
        }
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
