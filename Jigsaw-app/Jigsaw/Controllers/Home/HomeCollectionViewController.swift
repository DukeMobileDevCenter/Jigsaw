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
    
    private var queueType: PlayersQueue {
        playersCountSegmentedControl.selectedSegmentIndex == 0 ? .twoPlayersQueue : .fourPlayersQueue
    }
    
    // Create a lazy stored property for a custom UIBarButtonItem with an image of a game controller and text "Demo".
    // The button will call the demoButtonTapped method when tapped.
    private lazy var demoButton: UIBarButtonItem = {
        let gameControllerImage = UIImage(systemName: "gamecontroller")
        let button = UIButton(type: .system)
        button.setImage(gameControllerImage, for: .normal)
        button.setTitle("Demo", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16) // Decrease font size to fit title
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8) // Increase button width
        button.addTarget(self, action: #selector(demoButtonTapped), for: .touchUpInside)
        return UIBarButtonItem(customView: button)
    }()


//    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
//        testShowChatroom(sender)
//    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        navigationItem.title = Strings.HomeCollectionViewController.NavigationItem.title
    }
    
    private func testShowChatroom(_ sender: UIBarButtonItem) {
        let chatroomsRef = FirebaseConstants.chatrooms.document("TestChatroom")
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                let chatroomVC = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom, isDemo: false)
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
        // Aggressively set last load date, even if if fails to load, to avoid
        // additional bandwidth cost.
        Profiles.lastLoadGameDate = Date()
        // Load history first, then load games.
        ProgressHUD.dismiss()
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
            case .failure(let error):
                os_log(.error, "Error: loading games from remote")
                DispatchQueue.main.async {
                    self.presentAlert(error: error)
                }
            }
            DispatchQueue.main.async { [weak self] in
                self?.collectionView?.reloadData()
                self?.collectionView?.refreshControl?.endRefreshing()
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
        ProgressHUD.show("Loading", interaction: false)
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
        } else {
            // Do nothing if the games are up-to-date.
            ProgressHUD.dismiss()
        }
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to UIScrollView object.
        collectionView?.refreshControl = UIRefreshControl()
        collectionView?.refreshControl?.addTarget(self, action: #selector(loadFromRemote), for: .valueChanged)
    }
    
    private func isRandomCell(for indexPath: IndexPath) -> Bool {
        indexPath.item == GameCategory.allCases.count - 1
    }
    
    private func handleRandomPerform(for indexPath: IndexPath) {
        let cell = collectionView?.cellForItem(at: indexPath)
        if isRandomCell(for: indexPath) {
            // Handle random cell specifically.
            getGameWithLeastWaitingTime(queueType: queueType) { [unowned self] game in
                if let game = game {
                    self.randomGame = game
                    self.performSegue(withIdentifier: "showRandom", sender: cell)
                } else {
                    // If the query returns empty game result, show an alert.
                    self.presentAlert(title: Strings.HomeCollectionViewController.HandleRandomPerform.PresentAlert.title, message: Strings.HomeCollectionViewController.HandleRandomPerform.PresentAlert.message)
                }
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
    private func getGameWithLeastWaitingTime(queueType: PlayersQueue, completion: @escaping (_ game: Game?) -> Void) {
        let loadGroup = DispatchGroup()
        let moduloDivisor = queueType.playerCount
        // An array of (queue's player count mod by queue type) and (game) tuples.
        var moduloGamePairs = [(queuePlayerCountModulo: Int, game: Game)]()
        
        ProgressHUD.show(interaction: false)
        for game in GameStore.shared.allGames where game.isEnabled {
            let queuesRef = FirebaseConstants.gameQueueRef(gameName: game.gameName, queueType: queueType)
            loadGroup.enter()
            queuesRef.getDocuments { querySnapshot, _ in
                defer {
                    loadGroup.leave()
                }
                if let querySnapshot = querySnapshot {
                    let documentsCount = querySnapshot.documents.count
                    moduloGamePairs.append((documentsCount % moduloDivisor, game))
                }
            }
        }
        // When all queries are done, dismiss the HUD and pass back the game.
        loadGroup.notify(queue: .main) {
            ProgressHUD.dismiss()
            moduloGamePairs.sort { $0.queuePlayerCountModulo > $1.queuePlayerCountModulo }
            completion(moduloGamePairs.first?.game)
        }
    }
    
    @objc func demoButtonTapped(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: "showDemoCategory", sender: sender)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        playersCountSegmentedControl.isHidden = true
        reloadFromRemoteIfNeeded()
    }
    
    override func viewDidLoad() {
        // Do any additional setup after loading the view.
        super.viewDidLoad()
        // Set collection view delegates.
        collectionView?.delegate = self
        collectionView?.dataSource = GameCategoryClass.shared
        
        // configure demo button
        navigationItem.rightBarButtonItem = demoButton
        
        // Add an observer to monitor changed user ID and reload the data.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadFromRemote),
            name: .userIDChanged,
            object: nil
        )
        
        // Configure pull to refresh.
        configureRefreshControl()
        // Load games and player's game histories (if exist) from remote.
        loadFromRemote()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "showCategory":
            // Triggered by tapping on a category cell.
            if let cell = sender as? GameCollectionCell, let selectedIndexPath = collectionView?.indexPath(for: cell) {
                let selectedCategory = GameCategoryClass.shared.foundCategories[selectedIndexPath.item]
                let destinationVC = segue.destination as! CategoryViewController
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
            os_log(.info, "Random game is %s", randomGame.gameName)
        case"showDemoCategory":
            let destinationVC = segue.destination as! CategoryViewController
            destinationVC.title = "Demo Game"
            destinationVC.isDemo = true
            destinationVC.category = .demo
            destinationVC.queueType = queueType
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
}

// MARK: - UICollectionView

extension HomeCollectionViewController: UICollectionViewDelegateFlowLayout {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        handleRandomPerform(for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
   //     let collectionViewSize = collectionView.bounds.inset(by: collectionView.safeAreaInsets).size
        let collectionViewSize = collectionView.bounds.size
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
        let category = GameCategoryClass.shared.foundCategories[index]
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

    @IBAction func unwindToHome( _ seg: UIStoryboardSegue) {
        print("Unwound using \(seg.identifier)")
    }
}
