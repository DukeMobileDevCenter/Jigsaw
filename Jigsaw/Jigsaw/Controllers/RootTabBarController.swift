//
//  RootTabBarController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RootTabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Sign in anonymously for now. Add other sign in options later.
        Auth.auth().signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
                return
            }
            guard let user = result?.user else { return }
            let uid = user.uid
            Profiles.userID = uid
            // Randomize a display name for now. Add a skippable step to create name in onboarding.
            Profiles.displayName = ["p1", "p2", "p3", "p4"].randomElement()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // First time user
        if !OnboardingStateManager.shared.getOnboardingCompletedState() {
            let onboardingViewController = OnboardingViewController(taskRun: nil)
            onboardingViewController.onboardingManagerDelegate = self
            // don't allow user to dismiss the VC with sliding down.
            onboardingViewController.modalPresentationStyle = .fullScreen
            present(onboardingViewController, animated: true)
        } else {
            self.didCompleteOnboarding()
        }
    }
}

extension RootTabBarController: OnboardingManagerDelegate {
    func didCompleteOnboarding() {
        // Load from firebase to fill in user info.
        let db = Firestore.firestore()
        let docRef = db.collection("Players").document(Profiles.userID)
        // Get player info from remote.
        docRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
            }
            guard let document = document, document.exists else {
                // Impossible to come here.
                self.presentAlert(title: "Error: player doesn't exist.")
                return
            }
            do {
                if let currentPlayer = try document.data(as: Player.self) {
                    Profiles.displayName = currentPlayer.displayName
                    Profiles.jigsawValue = currentPlayer.jigsawValue
                    print(Profiles().description)
                }
            } catch {
                self.presentAlert(error: error)
            }
        }
    }
}
