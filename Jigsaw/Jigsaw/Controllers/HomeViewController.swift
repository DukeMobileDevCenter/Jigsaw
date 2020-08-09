//
//  HomeViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit
import FirebaseFirestore
import FirebaseAuth

class HomeViewController: UIViewController {
    var reviewVC: ORKReviewViewController!
    
    @IBAction func startOverWelcomePage(_ sender: UIButton) {
        if !GameStore.shared.allGames.isEmpty {
            let game = GameStore.shared.allGames.first!
            let gameOfMyGroup = GameOfGroup(version: game.version, gameName: game.gameName, resourceURL: game.g2resURL, questionnaire: game.g2Questionnaire)
            let taskViewController = GameViewController(game: gameOfMyGroup, taskRun: nil)
            taskViewController.delegate = self
            present(taskViewController, animated: true)
        }
    }
    
    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
//        show(reviewVC, sender: sender)
//        let vc = ChatViewController(user: currentUser, chatroom: "zY40mIdv1xnSxyB9GVPK")
        let chatroom = Chatroom(name: "US1")
        let chatroomRef = Firestore.firestore().collection("Chatrooms")
        do {
            _ = try chatroomRef.document(chatroom.id!).setData(from: chatroom)
        } catch {
            print("Error saving chatroom: \(error.localizedDescription)")
        }
        
        let chatroomVC = ChatViewController(user: Auth.auth().currentUser!, chatroom: chatroom)
        show(chatroomVC, sender: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
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
        }
    }
}

extension HomeViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed, .saved:
            if let error = error { presentAlert(error: error) }
            taskViewController.dismiss(animated: true)
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
            taskViewController.dismiss(animated: true, completion: nil)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}

extension HomeViewController: ORKReviewViewControllerDelegate {
    func reviewViewController(_ reviewViewController: ORKReviewViewController, didUpdate updatedResult: ORKTaskResult, source resultSource: ORKTaskResult) {
        print("✅ updatedResult")
    }
    
    func reviewViewControllerDidSelectIncompleteCell(_ reviewViewController: ORKReviewViewController) {
        print("✅ incompleted cell selected")
    }
}
