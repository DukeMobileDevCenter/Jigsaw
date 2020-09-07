//
//  HomeCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import FirebaseFirestore
import FirebaseAuth
import ProgressHUD

class HomeCollectionViewController: UICollectionViewController {
    /// The flow layout of the collection view.
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    /// The segmented control to switch 2 players or 4 players game.
    @IBOutlet private var playersCountSegmentedControl: UISegmentedControl!
    
    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
        // Maybe put a sort or filter button here.
        // Sort by date or name or category, etc.
        // filter by name and category.
        testShowChatroom(sender)
//        PopulateGamesFromYAML.shared.uploadGame()
//        testShowResultChart(sender)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        navigationItem.title = playersCountSegmentedControl.selectedSegmentIndex == 0 ? "Games - 2P" : "Games - 4P"
    }
    
    private func testShowResultChart(_ sender: UIBarButtonItem) {
        let controller = ResultStatsViewController()
        controller.resultPairs = [.correct: 3, .skipped: 1, .incorrect: 2]
        controller.hidesBottomBarWhenPushed = true
        self.show(controller, sender: sender)
    }
    
    private func testShowChatroom(_ sender: UIBarButtonItem) {
        let chatroomsRef = Firestore.firestore().collection("Chatrooms").document("TestChatroom1")
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            do {
                if let chatroom = try document?.data(as: Chatroom.self) {
                    let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom, timeLeft: nil)
                    // Don't show bottom tab bar.
                    chatroomVC.hidesBottomBarWhenPushed = true
                    self.show(chatroomVC, sender: sender)
                }
            } catch {
                self.presentAlert(error: error)
            }
        }
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
    
    private func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadGames), for: .valueChanged)
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameStore.shared
        
        // Configure pull to refresh.
        configureRefreshControl()
        // Load games from remote.
        loadGames()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                // For future decision on either game or category.
                print("Index path \(selectedIndexPath).")
                let selectedGame = GameStore.shared.allGames[selectedIndexPath.item]
                let destinationVC = segue.destination as! MatchingViewController
                destinationVC.games = GameStore.shared.allGames
                destinationVC.queueType = playersCountSegmentedControl.selectedSegmentIndex == 0 ? .twoPlayersQueue : .fourPlayersQueue
                destinationVC.selectedGame = selectedGame
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
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

extension HomeCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let index = indexPath.item
        let game = GameStore.shared.allGames[index]
        let identifier = "\(index)" as NSString
        
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: nil) { _ in
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
