//
//  HomeCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

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
//        PopulateGames.shared.uploadGame()
//        testShowResultChart(sender)
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        title = playersCountSegmentedControl.selectedSegmentIndex == 0 ? "Lobby - 2P" : "Lobby - 4P"
    }
    
    private func testShowResultChart(_ sender: UIBarButtonItem) {
        let controller = ResultStatsViewController()
        controller.resultPairs = [.correct: 3, .skipped: 1, .incorrect: 2]
        controller.hidesBottomBarWhenPushed = true
        self.show(controller, sender: sender)
    }
    
    private func testShowChatroom(_ sender: UIBarButtonItem) {
        let chatroomRef = Firestore.firestore().collection("Chatrooms")
        chatroomRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                if let chatroom = Chatroom(document: change.document), chatroom.id == "TestChatroom1" {
                    let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom, timeLeft: nil)
                    // Don't show bottom tab bar.
                    chatroomVC.hidesBottomBarWhenPushed = true
                    self.show(chatroomVC, sender: sender)
                }
            }
        }
    }
    
    @objc
    private func loadGames() {
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let games):
                // Update collection view UI here.
                DispatchQueue.main.async {
                    print(games.count)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
                print("Error: loading games from remote: \(error)")
            }
            // Reload collection view and dismiss the refresh control.
            DispatchQueue.main.async {
                self.collectionView.reloadSections(IndexSet(integer: 0))
                self.collectionView.refreshControl?.endRefreshing()
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
        
        // Configure pull to refresh.
        configureRefreshControl()
        
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameStore.shared
        
        ProgressHUD.show()
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let games):
                // Update collection view UI here.
                DispatchQueue.main.async {
                    print(games.count)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
                print("Error: loading games from remote: \(error)")
            }
            self.collectionView.reloadSections(IndexSet(integer: 0))
            ProgressHUD.dismiss()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showGame"?:
            if let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first {
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
