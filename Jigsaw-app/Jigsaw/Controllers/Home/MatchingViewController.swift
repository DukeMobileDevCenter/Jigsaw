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
    @IBOutlet var detailTextLabel: UILabel! {
        didSet {
            detailTextLabel.attributedText = try? Down(markdownString: selectedGame.detailText).toAttributedString()
        }
    }
    /// The label to show current players count in the waiting queue.
    @IBOutlet var playerCountLabel: UILabel!
    /// The label to show the game name and level.
    @IBOutlet var gameNameLabel: UILabel! {
        didSet {
            gameNameLabel.text = "\(selectedGame.gameName), level \(selectedGame.level)"
        }
    }
    /// The button to join the waiting queue.
    @IBOutlet var joinGameButton: UIButton!
    
    // MARK: Properties
    
    /// The selected game set by the parent view controller.
    var selectedGame: Game!
    /// The queue type set by the parent view controller.
    var queueType: PlayersQueue!
    
    /// The player's current game group.
    private var gameGroup: GameGroup!
    /// The player's allocated game resources, i.e. URLs and questionnaires.
    private var gameOfMyGroup: GameOfGroup!
    
    /// A collection reference to the waiting queue.
    private var queuesRef: CollectionReference {
        FirebaseConstants.database.collection(["Queues", selectedGame.gameName, queueType.rawValue].joined(separator: "/"))
    }
    
    // MARK: Properties that require reset
    
    private var gameGroupListener: ListenerRegistration?
    private var queuesListener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Listen to the waiting queue updates when in the matching page.
        queuesListener = queuesRef.addSnapshotListener { [weak self] querySnapshot, _ in
            self?.playerCountLabel.text = "\(querySnapshot?.documents.count ?? 0)"
        }
    }
    
    private func setGameGroupListener() {
        gameGroupListener = FirebaseConstants.shared.gamegroups.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    @IBAction func joinGameButtonTapped(_ sender: UIButton?) {
        addPlayerToPlayersQueue(queueReference: queuesRef)
        // Only start to listen to game group updates after the player joins a game/room.
        setGameGroupListener()
        sender?.isEnabled = false
    }
    
    private func addPlayerToPlayersQueue(queueReference: CollectionReference) {
        do {
            try queueReference.document(Profiles.currentPlayer.userID).setData(from: Profiles.currentPlayer)
        } catch {
            presentAlert(error: error)
        }
    }
    
    private func handleAddedMatchingGroup(group: GameGroup) {
        guard let game = selectedGame else { return }
        let urls: [URL]
        let questionnaires: [Questionnaire]
        // Find which subgroup does current player belong to.
        switch group.whichGroupContains(userID: Profiles.userID) {
        case 1:
            urls = game.group1resourceURLs
            questionnaires = game.group1Questionnaires
        case 2:
            urls = game.group2resourceURLs
            questionnaires = game.group2Questionnaires
        default:
            return
        }
        // Create a sub game group for current player.
        gameOfMyGroup = GameOfGroup(
            version: game.version,
            level: game.level,
            gameName: game.gameName,
            detailText: game.detailText,
            resourceURLs: urls,
            questionnaires: questionnaires,
            category: game.category
        )
        // Show the room progress view controller.
        performSegue(withIdentifier: "showProgress", sender: nil)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let currentGroup = try? change.document.data(as: GameGroup.self),
              // Only proceed if current player is in the matching group.
              currentGroup.whichGroupContains(userID: Profiles.userID) != nil else { return }
        // Only listen to added matching gamegroup events.
        switch change.type {
        case .added:
            handleAddedMatchingGroup(group: currentGroup)
        default:
            break
        }
    }
    
    deinit {
        // Remove player from queue when it exits the matching page.
        queuesRef.document(Profiles.userID).delete()
        // Remove the waiting queue listener when exiting the matching page.
        queuesListener?.remove()
        print("✅ matching VC deinit")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProgress" {
            let destinationVC = segue.destination as! RoomProgressViewController
            destinationVC.gameGroup = gameGroup
            destinationVC.gameOfMyGroup = gameOfMyGroup
        }
    }
}
