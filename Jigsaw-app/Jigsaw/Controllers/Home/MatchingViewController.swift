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
    var isChatroomShown: Bool = false
    var games: [Game]!
    
    var queueType: PlayersQueue!
    
    @IBOutlet var playerCountLabel: UILabel!
    
    private let database = Firestore.firestore()
    
    private var gameGroupListener: ListenerRegistration?
    private var chatroomListener: ListenerRegistration?
    private var queueListener: ListenerRegistration?
    
    private var gameGroupID: String?
    private var isFirstPlayer: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Matching players"
        
        let queueReference = database.collection(["Queues", "Immigration", queueType.rawValue].joined(separator: "/"))
        queueListener = queueReference.addSnapshotListener { [weak self] querySnapshot, _ in
            self?.playerCountLabel.text = "\(querySnapshot?.documents.count ?? 0)"
        }
        
        addPlayerToPlayersQueue(queueReference: queueReference)
        
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
            isFirstPlayer = group.group1.first == Profiles.userID
        } else {
            gameOfMyGroup = GameOfGroup(version: game.version, gameName: game.gameName, resourceURL: game.g2resURL, questionnaire: game.g2Questionnaire)
        }
        let taskViewController = GameViewController(game: gameOfMyGroup, taskRun: nil)
        taskViewController.delegate = self
        // Disallow dismiss by interactive swipe in iOS 13.
        taskViewController.isModalInPresentation = true
        present(taskViewController, animated: true)
    }
    
    private func removeMatchingGroup() {
        // Only let the first player in a game group to clean up, after game is done.
        if let groupID = gameGroupID, isFirstPlayer {
            database.collection("GameGroups").document(groupID).delete { error in
                if let error = error {
                    self.presentAlert(error: error)
                }
            }
        }
    }
    
    private func removeUserFromQueue() {
        let queueReference = database.collection(["Queues", "Immigration", queueType.rawValue].joined(separator: "/"))
        queueReference.document(Profiles.currentPlayer.userID).delete()
        navigationController?.popViewController(animated: true)
    }
    
    private func handleDocumentChange(_ change: DocumentChange) {
        do {
            if let currentGroup = try change.document.data(as: GameGroup.self) {
                switch change.type {
                case .added:
                    gameGroupID = change.document.documentID
                    handleMatchingGroup(group: currentGroup)
                default:
                    break
                }
            }
        } catch {
            // If dirty data persist in database.
            self.presentAlert(error: error)
        }
    }
    
    private func loadChatroom(completion: @escaping (Chatroom?) -> Void) {
        isChatroomShown = false
        let chatroomsRef = database.collection("Chatrooms")
        chatroomListener = chatroomsRef.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                completion(nil)
                return
            }
            snapshot.documentChanges.forEach { change in
                if let chatroom = Chatroom(document: change.document), chatroom.id == "TestChatroom1" {
                    completion(chatroom)
                }
            }
            completion(nil)
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
        if stepViewController.step?.identifier == "Countdown" && !isChatroomShown {
            let stepVC = stepViewController as! ORKActiveStepViewController
            loadChatroom { chatroom in
                guard let chatroom = chatroom else { return }
                let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom)
                self.isChatroomShown = true
                stepViewController.title = "Quit chat"
                stepViewController.show(chatroomVC, sender: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    stepVC.resume()
                }
            }
        }
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed, .saved:
            if let error = error { presentAlert(error: error) }
            taskViewController.dismiss(animated: true) { [weak self] in
                self?.removeMatchingGroup()
                // Also pop the matching VC. Subject to change.
                self?.navigationController?.popViewController(animated: true)
            }
        case .completed:
            // Access the first and last name from the review step
            //            if let signatureResult = signatureResult(taskViewController: taskViewController),
            //                let signature = signatureResult.signature {
            //                let defaults = UserDefaults.standard
            //                defaults.set(signature.givenName, forKey: "firstName")
            //                defaults.set(signature.familyName, forKey: "lastName")
            //            }
            
            print("✅ completed")
            print(taskViewController.result)
            taskViewController.dismiss(animated: true) { [weak self] in
                self?.removeMatchingGroup()
                // Also pop the matching VC. Subject to change.
                self?.navigationController?.popViewController(animated: true)
            }
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}
