//
//  MatchingViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/10/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseFirestoreSwift

class MatchingViewController: UIViewController {
    var games: [Game]!
    var selectedGame: Game!
    var queueType: PlayersQueue!
    
    private var isChatroomShown: Bool = false
    
    private var chatroomStepVC: ORKActiveStepViewController!
    private var chatroomVC: ChatViewController!
    
    @IBOutlet var playerCountLabel: UILabel!
    
    private let database = Firestore.firestore()
    private lazy var queueReference = database.collection(["Queues", selectedGame.gameName, queueType.rawValue].joined(separator: "/"))
    
    private var gameGroupListener: ListenerRegistration?
    private var chatroomListener: ListenerRegistration?
    private var queueListener: ListenerRegistration?
    
    /// The player's current game group.
    private var gameGroupID: String?
    private var gameGroup: GameGroup!
    
    private var myQuestionnaire: Questionnaire!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Matching players"
        
        queueListener = queueReference.addSnapshotListener { [weak self] querySnapshot, _ in
            self?.playerCountLabel.text = "\(querySnapshot?.documents.count ?? 0)"
        }
        
        let gameGroupRef = database.collection("GameGroups")
        gameGroupListener = gameGroupRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    @IBAction func joinGameButtonTapped(_ sender: UIButton) {
        addPlayerToPlayersQueue(queueReference: queueReference)
    }
    
    private func addPlayerToPlayersQueue(queueReference: CollectionReference) {
        do {
            try queueReference.document(Profiles.currentPlayer.userID).setData(from: Profiles.currentPlayer)
        } catch {
            presentAlert(error: error)
        }
    }
    
    private func handleMatchingGroup(group: GameGroup) {
        let game = games.first { $0.gameName == group.gameName }!
        let gameOfMyGroup: GameOfGroup
        if group.group1.contains(Profiles.userID) {
            // Current player is allocated to the first group.
            gameOfMyGroup = GameOfGroup(version: game.version, gameName: game.gameName, resourceURL: game.g1resURL, questionnaire: game.g1Questionnaire)
            // Hold a reference to my questionnaire to check answers.
            myQuestionnaire = game.g1Questionnaire
        } else if group.group2.contains(Profiles.userID) {
            // Current player is allocated to the second group.
            gameOfMyGroup = GameOfGroup(version: game.version, gameName: game.gameName, resourceURL: game.g2resURL, questionnaire: game.g2Questionnaire)
            // Hold a reference to my questionnaire to check answers.
            myQuestionnaire = game.g2Questionnaire
        } else {
            // Not my group, ignore.
            return
        }
        let taskViewController = GameViewController(game: gameOfMyGroup, taskRun: nil)
        taskViewController.delegate = self
        // Disallow dismiss by interactive swipe in iOS 13.
        taskViewController.isModalInPresentation = true
        present(taskViewController, animated: true)
    }
    
    private func removeMatchingGroup() {
        // Clean up the game group after game is done.
        if let groupID = gameGroupID {
            database.collection("GameGroups").document(groupID).delete()
        }
    }
    
    private func removeUserFromQueue() {
        queueReference.document(Profiles.currentPlayer.userID).delete()
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        do {
            if let currentGroup = try change.document.data(as: GameGroup.self) {
                switch change.type {
                case .added:
                    gameGroupID = change.document.documentID
                    gameGroup = currentGroup
                    handleMatchingGroup(group: currentGroup)
                case .modified:
                    handleReadyPlayerCountUpdate(group: currentGroup)
                default:
                    break
                }
            }
        } catch {
            // If dirty data persist in database.
            self.presentAlert(error: error)
        }
    }
    
    private func handleReadyPlayerCountUpdate(group: GameGroup) {
        if group.group1.contains(Profiles.userID) || group.group2.contains(Profiles.userID) {
            if group.chatroomReadyUserIDs.count == group.group1.count + group.group2.count {
                // All players are ready for chat.
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    // Start the timer in chatroom step VC and chatroom VC. Later to only use 1.
                    self?.chatroomStepVC.start()
                    self?.chatroomVC.fireTimer()
                    print("✅ chatroom timer kicked off!")
                }
            }
        } else {
            // Not my group, ignore.
            return
        }
    }
    
    private func loadChatroom(completion: @escaping (Chatroom) -> Void) {
        isChatroomShown = false
        let chatroomsRef = database.collection("Chatrooms").document(gameGroup.chatroomID)
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            do {
                if let chatroom = try document?.data(as: Chatroom.self) {
                    completion(chatroom)
                }
            } catch {
                self.presentAlert(error: error)
            }
        }
    }
    
    deinit {
        // Stop waiting in queue when player exit the matching page.
        // There might be some sync bug, if a player just quit a match while he is added to a group.
        removeUserFromQueue()
        gameGroupListener?.remove()
        chatroomListener?.remove()
        queueListener?.remove()
        print("✅ matching VC deinit")
    }
}

extension MatchingViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        if stepViewController.step?.identifier == "Countdown" {
            chatroomStepVC = stepViewController as? ORKActiveStepViewController
            // Mark the player who reached chatroom step as ready.
            if let groupID = gameGroupID {
                database.collection("GameGroups").document(groupID).updateData([
                    "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
                ])
            }
            // When the chatroom is dismissed, finish the step.
            if isChatroomShown {
                chatroomStepVC.finish()
                return
            }
            loadChatroom { [weak self] chatroom in
                guard let self = self else { return }
                self.isChatroomShown = true
                let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom, timeLeft: self.chatroomStepVC.timeRemaining)
                self.chatroomVC = chatroomVC
                stepViewController.title = "Quit chat"
                stepViewController.show(chatroomVC, sender: nil)
            }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Remove matching group from database.
        removeMatchingGroup()
        taskViewController.dismiss(animated: true)
        switch reason {
        case .discarded, .saved:
            print("💦 Canceled")
            // Log an unsuccessful game result.
        case .failed:
            if let error = error { presentAlert(error: error) }
            print("❌ Failed")
            // Log an game error.
        case .completed:
            print("✅ completed")
            print(taskViewController.result)
            // Log the real game result.
            let controller = ResultStatsViewController()
            controller.resultPairs = [.correct: 3, .skipped: 1, .incorrect: 2]
            controller.hidesBottomBarWhenPushed = true
            show(controller, sender: self)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}
