//
//  RoomProgressViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit
import FirebaseFirestore

class RoomProgressViewController: UIViewController {
    /// The label to show current room level, debug only.
    @IBOutlet var roomLevelLabel: UILabel!
    
    /// The player's current game group.
    var gameGroup: GameGroup!
    
    var gameOfMyGroup: GameOfGroup!
    
    /// The game results collected from each room.
    private var gameResults = [ORKTaskResult]()
    
    private var isChatroomShown = false
    private var attempts = 0
    private var currentRoom = 0
    
    private var chatroomStepVC: ORKActiveStepViewController!
    private var chatroomViewController: ChatViewController!
    private var gameViewController: GameViewController!
    
    private var gameGroupListener: ListenerRegistration?
    
    private func addGameHistory(gameHistory: GameHistory) {
        let historyRef = FirebaseConstants.database.collection(["Players", Profiles.userID, "gameHistory"].joined(separator: "/"))
        do {
            // Set a history with the group ID.
            try historyRef.document(gameGroup.id!).setData(from: gameHistory)
            // Insert the played game into history set.
            Profiles.playedGameIDs.insert(gameHistory.gameID)
        } catch {
            presentAlert(error: error)
        }
    }
    
    private func setGameGroupListener() {
        let gameGroupRef = FirebaseConstants.shared.gamegroups
        gameGroupListener = gameGroupRef.addSnapshotListener { [weak self] querySnapshot, error in
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach { change in
                self?.handleDocumentChange(change)
            }
        }
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let currentGroup = try? change.document.data(as: GameGroup.self),
            // Only proceed if current player is in the matching group.
            currentGroup.group1.contains(Profiles.userID) || currentGroup.group2.contains(Profiles.userID) else { return }
        
        switch change.type {
        case .modified:
            // Only handle count increment.
            if currentGroup.chatroomReadyUserIDs.count > gameGroup.chatroomReadyUserIDs.count {
                handleModifiedReadyPlayerCount(group: currentGroup)
            } else if currentGroup.gameAttemptedUserIDs.count > gameGroup.gameAttemptedUserIDs.count {
                handleModifiredAttemptedPlayerCount(group: currentGroup)
            } else if currentGroup.gameFinishedUserIDs.count > gameGroup.gameFinishedUserIDs.count {
                handleModifiedFinishedPlayerCount(group: currentGroup)
            }
        case .removed:
            // If any player dropped the game before they finish, the others cannot play anymore.
            if currentGroup.gameFinishedUserIDs.count != currentGroup.userIDCount {
                taskViewController(gameViewController, didFinishWith: .discarded, error: GameError.otherPlayerDropped)
            }
        default:
            break
        }
        // Hold a reference to the changed game group.
        gameGroup = GameGroup(id: change.document.documentID, group: currentGroup)
    }
    
    private func handleModifiedReadyPlayerCount(group: GameGroup) {
        if group.chatroomReadyUserIDs.count == group.userIDCount {
            // All players are ready for chat.
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [unowned self] in
                // Start the timer in chatroom step VC and chatroom VC. Later to only use 1.
                self.chatroomViewController.chatroomUserIDs = group.chatroomReadyUserIDs.sorted()
                // Show the back button if players want to terminate early.
                self.chatroomViewController.navigationItem.hidesBackButton = false
            }
        }
    }
    
    private func handleModifiredAttemptedPlayerCount(group: GameGroup) {
        if group.gameAttemptedUserIDs.count == group.userIDCount {
            // All players have reached the wait page.
            if group.gameFinishedUserIDs.count < group.gameAttemptedUserIDs.count {
                // Some players failed.
                // Reset the attempted array.
                FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                    "gameAttemptedUserIDs": FieldValue.arrayRemove([Profiles.userID!])
                ])
                // Go back to the chatroom.
                gameViewController.flipToPage(withIdentifier: "Countdown", forward: false, animated: true)
            } else {
                // All players have passed.
                gameViewController.goForward()
            }
        }
    }
    
    private func handleModifiedFinishedPlayerCount(group: GameGroup) {
        if group.gameFinishedUserIDs.count == group.userIDCount {
            // All player have passed. Do nothing here now.
        }
    }
    
    private func loadChatroom(completion: @escaping (Chatroom) -> Void) {
        isChatroomShown = false
        let chatroomsRef = FirebaseConstants.shared.chatrooms.document(gameGroup.chatroomID)
        chatroomsRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let document = document, let chatroom = Chatroom(document: document) {
                completion(chatroom)
            } else if let error = error {
                self.gameViewController.presentAlert(error: error)
            }
        }
    }
    
    private func removeMatchingGroup() {
        // Clean up the game group after game is done.
        FirebaseConstants.shared.gamegroups.document(gameGroup.id!).delete()
    }
    
    private func removeChatroom() {
        FirebaseConstants.shared.chatrooms.document(gameGroup.chatroomID).delete()
    }
    
    // ----------------------------------- Shit above -----------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        gameViewController = GameViewController(game: gameOfMyGroup, currentRoom: currentRoom)
        gameViewController.delegate = self
        // Disallow dismiss by interactive swipe in iOS 13.
        gameViewController.isModalInPresentation = true
        present(gameViewController, animated: true)
    }
}

extension RoomProgressViewController: ORKTaskViewControllerDelegate {
    private func handleCountdownStep(taskViewController: ORKTaskViewController, stepViewController: ORKActiveStepViewController) {
        if isChatroomShown {
            return
        }
        chatroomStepVC = stepViewController
        
        if chatroomViewController == nil {
            loadChatroom { [weak self] chatroom in
                guard let self = self else { return }
                self.isChatroomShown = true
                let chatroomVC = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom)
                self.chatroomViewController = chatroomVC
                stepViewController.title = "Quit chat"
                stepViewController.show(chatroomVC, sender: nil)
                // Mark the player who reached chatroom step as ready.
                FirebaseConstants.shared.gamegroups.document(self.gameGroup.id!).updateData([
                    "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
                ])
                // Hide the back button until all players join the chatroom.
                chatroomVC.navigationItem.hidesBackButton = true
            }
        } else {
            isChatroomShown = true
            stepViewController.title = "Quit chat"
            stepViewController.show(chatroomViewController, sender: nil)
            // Mark the player who reached chatroom step as ready.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            // Hide the back button until all players join the chatroom.
            chatroomViewController.navigationItem.hidesBackButton = true
        }
    }
    
    private func handleQuestionsInstructionStep() {
        // When current player reached the questions instruction step, remove it from the array.
        FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
            "chatroomReadyUserIDs": FieldValue.arrayRemove([Profiles.userID!])
        ])
        // Reset flag for chatroom
        isChatroomShown = false
    }
    
    private func handleWaitStep(taskViewController: ORKTaskViewController, stepViewController: ORKWaitStepViewController) {
        // Everytime the player reaches wait step, it means he attempted the game.
        attempts += 1
        // Mark the player as attempted.
        let gameResult = GameResult(taskResult: taskViewController.result, questionnaire: questionnaires[currentRoom])
        let progress = CGFloat(gameGroup.gameAttemptedUserIDs.count + 1) / CGFloat(gameGroup.userIDCount)
        stepViewController.setProgress(progress, animated: true)
        // Add user ID to attempted array.
        // Note: it must go after the alert is presented. Otherwise it would cause
        // nav stack bug for not being able to pop while alert is presenting.
        let completion = { [weak self] in
            guard let self = self else { return }
            FirebaseConstants.shared.gamegroups.document(self.gameGroup.id!).updateData([
                "gameAttemptedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            return
        }
        if !gameResult.isPassed {
            // Failed to pass the game.
            if attempts == 2 {
                // First go to completion to notify the other players.
                completion()
                // Then fail the local game and abort.
                self.taskViewController(taskViewController, didFinishWith: .failed, error: GameError.maxAttemptReached)
            } else {
                stepViewController.presentAlert(gameError: GameError.currentPlayerFailed(gameResult.wrongCount), completion: completion)
            }
        } else {
            // Mark the player as finished.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "gameFinishedUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            completion()
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        guard let step = stepViewController.step else { return }
        switch step.identifier {
        case "Countdown":
            handleCountdownStep(taskViewController: taskViewController, stepViewController: stepViewController as! ORKActiveStepViewController)
        case "QuestionsInstruction":
            handleQuestionsInstructionStep()
        case "Wait":
            handleWaitStep(taskViewController: taskViewController, stepViewController: stepViewController as! ORKWaitStepViewController)
        default:
            break
        }
    }
    
    private func cleanUpAfterGameEnds() {
        // Stop listen to further updates to game groups.
        gameGroupListener?.remove()
        // Remove matching group from database.
        removeMatchingGroup()
        // Remove the chatroom when a player stops the game.
        removeChatroom()
        // Reset VCs.
        chatroomStepVC = nil
        chatroomViewController = nil
        // Reset attempts.
        attempts = 0
        // Reset flag for chatroom.
        isChatroomShown = false
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        // Hold current room's result.
        gameResults.append(taskViewController.result)
        // Clean ups.
        cleanUpAfterGameEnds()
        // Re-enable the button to allow player to join another game.
        joinGameButton.isEnabled = true
        // Dismiss the game VC.
        taskViewController.dismiss(animated: true)
        switch reason {
        case .failed:
            print("❌ Failed")
            if let error = error {
                if let gameError = error as? GameError {
                    presentAlert(gameError: gameError)
                } else {
                    presentAlert(error: error)
                }
            }
            // Log an game error.
        case .discarded, .saved:
            print("💦 Canceled")
            if let error = error {
                if let gameError = error as? GameError {
                    presentAlert(gameError: gameError)
                } else {
                    presentAlert(error: error)
                }
            }
            // Log an unsuccessful game result.
        case .completed:
            print("✅ completed")
            
            // Log the real game result.
            let gameResult = GameResult(taskResult: taskViewController.result, questionnaires: questionnaires)
            let controller = UIStoryboard(name: "ResultStatsViewController", bundle: .main).instantiateInitialViewController() as! ResultStatsViewController
            controller.resultPairs = gameResult.resultPairs
            controller.nextGame = GameStore.shared.nextGame(for: selectedGame)
            
            let gameHistory = GameHistory(
                gameID: selectedGame.gameID,
                playedDate: gameGroup.createdDate,
                gameCategory: selectedGame.category,
                gameName: selectedGame.gameName,
                allPlayers: gameGroup.group1 + gameGroup.group2,
                gameResult: Dictionary(uniqueKeysWithValues: Array(gameResult.resultPairs)),
                score: gameResult.score
            )
            // Add game history to a player's collection.
            addGameHistory(gameHistory: gameHistory)
            controller.hidesBottomBarWhenPushed = true
            show(controller, sender: self)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}
