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
    // MARK: Storyboard views
    
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
    
    // MARK: Properties that do not change between sessions
    
    /// The selected game set by parent view controller.
    var selectedGame: Game!
    /// The queue type set by parent view controller.
    var queueType: PlayersQueue!
    /// A collection reference to the waiting queue.
    private var queuesRef: CollectionReference {
        FirebaseConstants.database.collection(["Queues", selectedGame.gameName, queueType.rawValue].joined(separator: "/"))
    }
    
    // MARK: Properties that require reset for each session
    
    /// The player's current game group.
    private var gameGroup: GameGroup!
    /// The questionnaire for current game/room.
    private var myQuestionnaire: Questionnaire!
    
    private var isChatroomShown = false
    private var attempts = 0
    private var gameGroupListener: ListenerRegistration?
    private var queuesListener: ListenerRegistration?
    
    private var chatroomStepVC: ORKActiveStepViewController!
    private var chatroomVC: ChatViewController!
    private var gameVC: GameViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Matching"
        // Always listen to the waiting queue updates when in the matching page.
        setQueuesListener()
    }
    
    private func setQueuesListener() {
        queuesListener = queuesRef.addSnapshotListener { [weak self] querySnapshot, _ in
            self?.playerCountLabel.text = "\(querySnapshot?.documents.count ?? 0)"
        }
    }
    
    private func setGameGroupListener() {
        let gameGroupRef = FirebaseConstants.shared.gamegroups
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
        addPlayerToPlayersQueue(queueReference: queuesRef)
        // Only start to listen to game group updates after the player joins a game/room.
        setGameGroupListener()
        sender.isEnabled = false
    }
    
    private func addPlayerToPlayersQueue(queueReference: CollectionReference) {
        do {
            try queueReference.document(Profiles.currentPlayer.userID).setData(from: Profiles.currentPlayer)
        } catch {
            presentAlert(error: error)
        }
    }
    
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
    
    private func handleAddedMatchingGroup(group: GameGroup) {
        let game = selectedGame!
        let url: URL
        // Find which subgroup does current player belong to.
        switch group.whichGroupContains(userID: Profiles.userID) {
        case 1:
            url = game.g1resURL
            myQuestionnaire = game.g1Questionnaire
        case 2:
            url = game.g2resURL
            myQuestionnaire = game.g2Questionnaire
        default:
            return
        }
        // Create a sub game group for current player.
        let gameOfMyGroup = GameOfGroup(
            version: game.version,
            gameName: game.gameName,
            detailText: game.detailText,
            resourceURL: url,
            questionnaire: myQuestionnaire
        )
        
        gameVC = GameViewController(game: gameOfMyGroup)
        gameVC.delegate = self
        // Disallow dismiss by interactive swipe in iOS 13.
        gameVC.isModalInPresentation = true
        present(gameVC, animated: true)
    }
    
    private func removeMatchingGroup() {
        // Clean up the game group after game is done.
        FirebaseConstants.shared.gamegroups.document(gameGroup.id!).delete()
    }
    
    private func removeChatroom() {
        FirebaseConstants.shared.chatrooms.document(gameGroup.chatroomID).delete()
    }
    
    private func removeUserFromQueue() {
        queuesRef.document(Profiles.userID).delete()
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        guard let currentGroup = try? change.document.data(as: GameGroup.self),
            // Only proceed if current player is in the matching group.
            currentGroup.group1.contains(Profiles.userID) || currentGroup.group2.contains(Profiles.userID) else { return }
        
        switch change.type {
        case .added:
            handleAddedMatchingGroup(group: currentGroup)
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
                taskViewController(gameVC, didFinishWith: .discarded, error: GameError.otherPlayerDropped)
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
                self.chatroomVC.chatroomUserIDs = group.chatroomReadyUserIDs.sorted()
                self.chatroomStepVC.start()
                self.chatroomVC.start()
                print("✅ chatroom timer kicked off!")
                // Show the back button if players want to terminate early.
                self.chatroomVC.navigationItem.hidesBackButton = false
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
                gameVC.flipToPage(withIdentifier: "Countdown", forward: false, animated: true)
            } else {
                // All players have passed.
                gameVC.goForward()
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
                self.gameVC.presentAlert(error: error)
            }
        }
    }
    
    deinit {
        // Remove player from queue when it exits the matching page.
        // There might be some sync bug, if a player just quit a match while he is added to a group.
        removeUserFromQueue()
        // Remove the waiting queue listener when exiting the matching page.
        queuesListener?.remove()
        print("✅ matching VC deinit")
    }
}

extension MatchingViewController: ORKTaskViewControllerDelegate {
    private func handleCountdownStep(taskViewController: ORKTaskViewController, stepViewController: ORKActiveStepViewController) {
        if isChatroomShown {
            chatroomStepVC.finish()
            chatroomVC.finish()
            return
        }
        chatroomStepVC = stepViewController
        
        if chatroomVC == nil {
            loadChatroom { [weak self] chatroom in
                guard let self = self else { return }
                self.isChatroomShown = true
                let chatroomVC = ChatViewController(user: FirebaseConstants.auth.currentUser!, chatroom: chatroom, timeLeft: stepViewController.timeRemaining)
                self.chatroomVC = chatroomVC
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
            chatroomVC.timeLeft = stepViewController.timeRemaining
            stepViewController.title = "Quit chat"
            stepViewController.show(chatroomVC, sender: nil)
            // Mark the player who reached chatroom step as ready.
            FirebaseConstants.shared.gamegroups.document(gameGroup.id!).updateData([
                "chatroomReadyUserIDs": FieldValue.arrayUnion([Profiles.userID!])
            ])
            // Hide the back button until all players join the chatroom.
            chatroomVC.navigationItem.hidesBackButton = true
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
        let gameResult = GameResult(taskResult: taskViewController.result, questionnaire: myQuestionnaire)
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
        // Invalidate any remaining timer.
        chatroomStepVC?.finish()
        chatroomVC?.finish()
        // Reset VCs.
        chatroomStepVC = nil
        chatroomVC = nil
        // Reset attempts.
        attempts = 0
        // Reset flag for chatroom.
        isChatroomShown = false
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
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
            let gameResult = GameResult(taskResult: taskViewController.result, questionnaire: myQuestionnaire)
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
