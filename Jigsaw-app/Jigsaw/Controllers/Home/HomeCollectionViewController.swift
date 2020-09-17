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
        let chatroomsRef = Firestore.firestore().collection("Chatrooms").document("TestChatroom")
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom, timeLeft: nil)
                // Don't show bottom tab bar.
                chatroomVC.hidesBottomBarWhenPushed = true
                self.show(chatroomVC, sender: sender)
            } else if let error = error {
                self.presentAlert(error: error)
            }
        }
    }
    
    @objc
    private func loadGames() {
        ProgressHUD.show("Loading")
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let games):
                os_log(.info, "games count = %d", games.count)
            case .failure(let error):
                os_log(.error, "Error: loading games from remote")
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.refreshControl?.endRefreshing()
            }
        }
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadGames), for: .valueChanged)
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameCategoryClass.shared
        
        // Configure pull to refresh.
        configureRefreshControl()
        // Load games from remote.
        loadGames()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategory"?:
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                let selectedCategory = GameCategoryClass.shared.allCases[selectedIndexPath.item]
                let destinationVC = segue.destination as! CategoryCollectionViewController
                destinationVC.title = selectedCategory.label
                destinationVC.category = selectedCategory
                destinationVC.queueType = playersCountSegmentedControl.selectedSegmentIndex == 0 ? .twoPlayersQueue : .fourPlayersQueue
                // Tell the data source that a category should be displayed.
                GameStore.shared.selectedCategory = selectedCategory
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
        let category = GameCategoryClass.shared.allCases[index]
        let identifier = "\(index)" as NSString
        let previewControllerProvider = { () -> UIViewController? in
            let storyboard = UIStoryboard(name: "PreviewDetailViewController", bundle: .main)
            let controller = storyboard.instantiateInitialViewController() as! PreviewDetailViewController
            controller.structToPreview = category
            return controller
        }
        // Return the preview without menu items.
        return UIContextMenuConfiguration(identifier: identifier, previewProvider: previewControllerProvider)
    }
    
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let identifier = configuration.identifier as? String,
            let item = Int(identifier) else { return }
        
        let cell = collectionView.cellForItem(at: IndexPath(item: item, section: 0))
        
        animator.addCompletion {
            self.performSegue(withIdentifier: "showCategory", sender: cell)
        }
    }
}
