//
//  HomeCollectionViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import FirebaseAuth
import ProgressHUD

class HomeCollectionViewController: UICollectionViewController {
    /// The flow layout of the collection view.
    @IBOutlet private var collectionViewFlowLayout: UICollectionViewFlowLayout!
    /// The segmented control to switch 2 players or 4 players game.
    @IBOutlet private var playersCountSegmentedControl: UISegmentedControl!
    
    private var randomGame: Game!
    var nextGame: Game!
    
    private var queueType: PlayersQueue {
        playersCountSegmentedControl.selectedSegmentIndex == 0 ? .twoPlayersQueue : .fourPlayersQueue
    }
    
    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
        // Maybe put a sort or filter button here.
        // Sort by date or name or category, etc.
        // filter by name and category.
        testShowChatroom(sender)
//        PopulateGamesFromYAML.shared.uploadGame()
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        navigationItem.title = playersCountSegmentedControl.selectedSegmentIndex == 0 ? "Games - 2P" : "Games - 4P"
    }
    
    private func testShowChatroom(_ sender: UIBarButtonItem) {
        let chatroomsRef = FirebaseConstants.shared.chatrooms.document("TestChatroom")
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                let chatroomVC = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom)
                // Don't show bottom tab bar.
                chatroomVC.hidesBottomBarWhenPushed = true
                self.show(chatroomVC, sender: sender)
            } else if let error = error {
                self.presentAlert(error: error)
            }
        }
    }
    
    /// Load games and player's game histories (if exist) from remote.
    @objc
    private func loadFromRemote() {
        // Load history first, then load games.
        loadHistories { [weak self] in
            self?.loadGames()
        }
    }
    
    private func loadGames() {
        ProgressHUD.show("Loading", interaction: false)
        // Asynchronously load the games from Firebase.
        GameStore.shared.loadGames { [weak self] result in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            switch result {
            case .success(let games):
                os_log(.info, "games count = %d", games.count)
                Profiles.lastLoadGameDate = Date()
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
    
    private func loadHistories(completion: (() -> Void)? = nil) {
        guard Profiles.userID != nil else { return }
        FirebaseHelper.getGameHistory(userID: Profiles.userID) { [weak self] histories, error in
            if let histories = histories {
                // Add all remote histories to the set.
                Profiles.playedGameIDs = Set(histories.map { $0.gameID })
                completion?()
            } else if let error = error {
                DispatchQueue.main.async {
                    self?.presentAlert(error: error)
                }
            }
        }
    }
    
    /// Read from `UserDefaults` to get last load game date. If the date is before today, reload the game and player histories.
    /// This is assuming the app session is not killed overnight, and should check daily if new games/histories are added.
    private func reloadFromRemoteIfNeeded() {
        guard let lastLoadGameDate = Profiles.lastLoadGameDate else {
            // Last date does not exist. Load anyway.
            loadFromRemote()
            return
        }
        let dateNow = Date()
        let startOfToday = Calendar.current.startOfDay(for: dateNow)
        let interval = dateNow.timeIntervalSince(lastLoadGameDate)
        if interval > dateNow.timeIntervalSince(startOfToday) {
            // If the game is last loaded before today.
            loadFromRemote()
        }
        // Do nothing if the games are up-to-date.
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to UIScrollView object.
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(loadFromRemote), for: .valueChanged)
    }
    
    private func isRandomCell(for indexPath: IndexPath) -> Bool {
        indexPath.item == GameCategory.allCases.count - 1
    }
    
    private func handleRandomPerform(for indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if isRandomCell(for: indexPath) {
            // Handle random cell specifically.
            getGameWithLeastWaitingTime(queueType: queueType) { [unowned self] game in
                self.randomGame = game
                self.performSegue(withIdentifier: "showRandom", sender: cell)
            }
        } else {
            // Do the normal synchronous performSegue.
            performSegue(withIdentifier: "showCategory", sender: cell)
        }
    }
    
    /// Find the game queue with least waiting time. See more in #59.
    /// 
    /// - Parameters:
    ///   - queueType: The players queue type, 2 or 4 players.
    ///   - completion: Return the game after sorting all games by their modulos.
    ///   - game: The game with the largest modulo.
    private func getGameWithLeastWaitingTime(queueType: PlayersQueue, completion: @escaping (_ game: Game) -> Void) {
        let loadGroup = DispatchGroup()
        let moduloDivisor = queueType == .twoPlayersQueue ? 2 : 4
        // An array of (queue's player count mod by queue type) and (game) tuples.
        var moduloGamePairs = [(queuePlayerCountModulo: Int, game: Game)]()
        
        ProgressHUD.show(interaction: false)
        for game in GameStore.shared.allGames {
            if game.level != 1 { break }
            let queuesRef = FirebaseConstants.database.collection(["Queues", game.gameName, queueType.rawValue].joined(separator: "/"))
            loadGroup.enter()
            queuesRef.getDocuments { querySnapshot, error in
                defer {
                    loadGroup.leave()
                }
                if error != nil {
                    os_log(.error, "Error: finding the quickest game from remote")
                } else if let querySnapshot = querySnapshot {
                    let documentsCount = querySnapshot.documents.count
                    moduloGamePairs.append((documentsCount % moduloDivisor, game))
                }
            }
        }
        // When all queries are done, dismiss the HUD and pass back the game.
        loadGroup.notify(queue: .main) {
            ProgressHUD.dismiss()
            moduloGamePairs.sort { $0.queuePlayerCountModulo > $1.queuePlayerCountModulo }
            completion(moduloGamePairs.first!.game)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Check if reload from remote is needed everytime when the view will appear.
        reloadFromRemoteIfNeeded()
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView.delegate = self
        collectionView.dataSource = GameCategoryClass.shared
        
        // Configure pull to refresh.
        configureRefreshControl()
        // Load games and player's game histories (if exist) from remote.
        loadFromRemote()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategory":
            // Triggered by tapping on a category cell.
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView.indexPath(for: cell) {
                let selectedCategory = GameCategoryClass.shared.allCases[selectedIndexPath.item]
                let destinationVC = segue.destination as! CategoryCollectionViewController
                destinationVC.title = selectedCategory.label
                destinationVC.category = selectedCategory
                destinationVC.queueType = queueType
                // Tell the data source that a category should be displayed.
                GameStore.shared.selectedCategory = selectedCategory
            }
        case "showRandom":
            // Triggered by tapping on the "Random" cell.
            let destinationVC = segue.destination as! MatchingViewController
            destinationVC.queueType = queueType
            destinationVC.selectedGame = randomGame
            print("Info: Random game is \(randomGame.gameName)")
        case "showSpecific":
            let destinationVC = segue.destination as! MatchingViewController
            destinationVC.queueType = queueType
            destinationVC.selectedGame = nextGame
//            // Auto join the next level room.
//            if let resultTabSenderID = sender as? String, resultTabSenderID == "ResultStatsViewController" {
//                destinationVC.joinGameButtonTapped(nil)
//            }
            print("Info: Next game is \(nextGame.gameName)")
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

extension HomeCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleRandomPerform(for: indexPath)
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
        
        let indexPath = IndexPath(item: item, section: 0)
        // Handle the random game cell separately.
        animator.addCompletion {
            self.handleRandomPerform(for: indexPath)
        }
    }
}
