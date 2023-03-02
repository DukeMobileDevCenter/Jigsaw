//
//  MatchingViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/10/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseFirestoreSwift
import Down

class MatchingViewController: UIViewController {
    // MARK: Storyboard views
    
    /// The label to show the detail text of a game.
    @IBOutlet weak var detailTextView: UITextView! {
        didSet {
            let attributedText = try? Down(markdownString: selectedGame.detailText).toAttributedString(.default, stylesheet: AppConstants.simpleStylesheet)
            detailTextView.attributedText = attributedText?.labelColorAttributedString
        }
    }
    /// The label to show current players count in the waiting queue.
    @IBOutlet var playerCountLabel: UILabel!
    /// The label to show the game name and level.
    @IBOutlet var gameNameLabel: UILabel! {
        didSet {
            if !isDemo {
                gameNameLabel.text = "\(selectedGame.gameName). Good luck! 😉"
            }
        }
    }
    /// The button to join the waiting queue.
    @IBOutlet var joinGameButton: UIButton!
    
    // MARK: Properties
    
    /// A flag indicating whether the current game is a demo or not.
    var isDemo = false
    
    /// The selected game set by the parent view controller.
    var selectedGame: Game!
    /// The queue type set by the parent view controller.
    var queueType: PlayersQueue!
    
    /// The player's current game group.
    private var gameGroup: GameGroup!
    /// The player's allocated game resources, i.e. URLs and questionnaires.
    private var gameOfMyGroup: GameOfGroup!
    
    /// A collection reference to the waiting queue.
    private var queuesRef: CollectionReference!
    
    // Properties that require reset
    
    private var gameGroupListener: ListenerRegistration?
    private var queuesListener: ListenerRegistration?
    
    // MARK: Methods to handle player matching
    
    private func addPlayerToPlayersQueue(queueReference: CollectionReference) {
        do {
            try queueReference.document(Profiles.currentPlayer.userID).setData(from: Profiles.currentPlayer)
        } catch {
            presentAlert(error: error)
        }
    }
    
    private func handleAddedMatchingGroup(group: GameGroup) {
        guard
            let game = selectedGame,
            // The new group must have the correct game, to mitigate #117.
            group.gameName == game.gameName,
            // The new game must be created within 10 seconds, to avoid #117.
            Date().timeIntervalSince(group.createdDate) < 10
        else { return }
        
        let contents: [String]
        let questionnaires: [Questionnaire]
        // Find which subgroup does current player belong to.
        switch group.whichGroupContains(userID: Profiles.userID) {
        case 1:
            contents = game.group1resourceContents
            questionnaires = game.group1Questionnaires
        case 2:
            contents = game.group2resourceContents
            questionnaires = game.group2Questionnaires
        default:
            return
        }
        // Create a sub game group for current player.
        gameOfMyGroup = GameOfGroup(
            version: game.version,
            level: game.level,
            maxAttempts: game.maxAttempts,
            gameID: game.gameID,
            gameName: game.gameName,
            detailText: game.detailText,
            resourceContent: contents,
            questionnaires: questionnaires,
            category: game.category
        )
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        gameGroupListener = nil
        // Show the room progress view controller.
        performSegue(withIdentifier: "showProgress", sender: nil)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let currentGroup = try? change.document.data(as: GameGroup.self),
              // Only proceed if current player is in the matching group.
              currentGroup.whichGroupContains(userID: Profiles.userID) != nil else { return }
        gameGroup = GameGroup(id: change.document.documentID, group: currentGroup)
        // Only listen to added matching gamegroup events.
        switch change.type {
        case .added:
            handleAddedMatchingGroup(group: currentGroup)
        default:
            break
        }
    }
    
    private func setGameGroupListener() {
        // Listen to game group changes when the player joined a waiting queue.
        gameGroupListener = FirebaseConstants.gamegroups.addSnapshotListener { [weak self] querySnapshot, _ in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func joinGameButtonTapped(_ sender: UIButton) {
        if !isDemo {
            addPlayerToPlayersQueue(queueReference: queuesRef)
            // Only start to listen to game group updates after the player joins a game/room.
            setGameGroupListener()
            sender.isEnabled = false
        } else {
            // Show the room progress view controller.
            performSegue(withIdentifier: "showProgress", sender: nil)
        }
        
    }
    
    // MARK: UIViewController
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProgress" {
            let destinationVC = segue.destination as! RoomProgressViewController
            if !isDemo {
                destinationVC.gameGroup = gameGroup
                destinationVC.gameOfMyGroup = gameOfMyGroup
                // Record the game group ID to handle crash.
                Profiles.currentGroupID = gameGroup.id
            } else {
                destinationVC.isDemo = true
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isDemo {
            playerCountLabel.text = "1"
            gameNameLabel.text = "Let's go for a demo game!"
        } else {
            queuesRef = FirebaseConstants.gameQueueRef(gameName: selectedGame.gameName, queueType: queueType)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isDemo {
            // Listen to the waiting queue updates when in the matching page.
            queuesListener = queuesRef.addSnapshotListener { [weak self] querySnapshot, _ in
                guard let snapshot = querySnapshot else { return }
                self?.playerCountLabel.text = "\(snapshot.documents.count)"
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // When matching page is not showing anymore:
        // Remove the waiting queue listener.
        queuesListener?.remove()
        queuesListener = nil
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        gameGroupListener = nil
    }
    
    deinit {
        if !isDemo {
            // Remove player from queue when it exits the matching page.
            queuesRef.document(Profiles.userID).delete()
        }
    }
}
