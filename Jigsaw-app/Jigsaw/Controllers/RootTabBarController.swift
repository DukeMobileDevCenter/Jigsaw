//
//  RootTabBarController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import FirebaseAuth

class RootTabBarController: UITabBarController {
    var isFirstAppearance = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Only load player info once per app launch.
        guard isFirstAppearance else { return }
        // An instance to FirebaseAuth.
        let auth = Auth.auth()
        // First time user.
        if !OnboardingStateManager.shared.getOnboardingCompletedState() {
            // Sign in anonymously for now. Add other sign in options later.
            signInAnonymously(auth: auth)
            let onboardingViewController = OnboardingViewController(taskRun: nil)
            onboardingViewController.onboardingManagerDelegate = self
            // Disallow dismiss by interactive swipe down in iOS 13.
            onboardingViewController.isModalInPresentation = true
            present(onboardingViewController, animated: true)
        } else {
            // Already went through the new user workflow and have credentials in keychain.
            if let currentUser = auth.currentUser {
                if Profiles.userID != currentUser.uid {
                    self.presentAlert(title: "❌ Something wrong with existing user", message: "This should never happen unless storage is corrupted.")
                }
                Profiles.userID = currentUser.uid
                
            } else {
                print("❌ Error loading existing user. This shoudn't happen unless user get deleted on remote or log out explicitly.")
                // Handle re-login here.
            }
            didCompleteOnboarding()
        }
        isFirstAppearance = false
    }
    
    private func signInAnonymously(auth: Auth, completion: (() -> Void)? = nil) {
        auth.signInAnonymously { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
                return
            }
            guard let user = result?.user else { return }
            let uid = user.uid
            if Profiles.userID == nil {
                Profiles.userID = uid
            } else if Profiles.userID != uid {
                self.presentAlert(title: "Something wrong with anonymous user", message: "This should never happen unless database is corrupted.")
            }
            completion?()
        }
    }
    
    private func setCurrentPlayer(with userID: String) {
        // Load from firebase to fill in user info.
        let docRef = FirebaseConstants.shared.players.document(userID)
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
                    Profiles.currentPlayer = currentPlayer
                    print(Profiles().description)
                }
            } catch {
                self.presentAlert(error: error)
            }
        }
    }
}

extension RootTabBarController: OnboardingManagerDelegate {
    func didCompleteOnboarding() {
        setCurrentPlayer(with: Profiles.userID)
    }
}
