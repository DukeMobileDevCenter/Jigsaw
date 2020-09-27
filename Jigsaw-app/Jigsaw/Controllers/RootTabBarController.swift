//
//  RootTabBarController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import FirebaseAuth
import ProgressHUD

class RootTabBarController: UITabBarController {
    /// A boolean to record if the tab bar controller is seen for the first time.
    private var isFirstLaunch = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Only load sign in page once per app launch.
        guard isFirstLaunch else { return }
        // An FirebaseAuth object that handles user sign in.
        let auth = Auth.auth()
        // Present the sign in view controller as the first page.
        let controller = UIStoryboard(name: "SignInViewController", bundle: .main).instantiateInitialViewController() as! SignInViewController
        controller.auth = auth
        controller.signInManagerDelegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: false)
        
        ProgressHUD.show()
        // Check if the user is signed in.
        auth.addStateDidChangeListener { [weak self, unowned controller] auth, user in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            // Unsafely updated the controller's auth.
            controller.auth = auth
            if let user = user {
                // User is signed in, dismiss the sign in page.
                controller.dismiss(animated: true) { [weak self] in
                    self?.handleAfterSignIn(user: user)
                }
            }
            // Retain the sign in page when no user is signed in.
        }
        isFirstLaunch = false
    }
    
    private func handleAfterSignIn(user: User) {
        switch OnboardingStateManager.shared.getOnboardingCompletedState() {
        case true:
            // Existing user, fetch from remote directly.
            if Profiles.userID != user.uid {
                // A new user signed in.
                Profiles.userID = user.uid
            }
            didCompleteOnboarding()
        case false:
            // Newly signed in user.
            let controller = OnboardingViewController(taskRun: nil)
            controller.onboardingManagerDelegate = self
            // Disallow dismiss-by-interactive-swipe-down for iOS 13 and above.
            controller.isModalInPresentation = true
            present(controller, animated: false)
        }
    }
    
    private func setCurrentPlayer(with userID: String) {
        FirebaseHelper.getPlayer(userID: userID) { [weak self] player, error in
            guard let self = self else { return }
            if let currentPlayer = player {
                Profiles.displayName = currentPlayer.displayName
                Profiles.jigsawValue = currentPlayer.jigsawValue
                Profiles.currentPlayer = currentPlayer
                print(Profiles().description)
            } else if let error = error {
                self.presentAlert(error: error)
                os_log(.error, "Failed to get player from remote: %@", error.localizedDescription)
            }
        }
    }
}

extension RootTabBarController: OnboardingManagerDelegate {
    func didCompleteOnboarding() {
        setCurrentPlayer(with: Profiles.userID)
    }
}

extension RootTabBarController: SignInManagerDelegate {
    func didCompleteSignIn(withAnonymousUser user: User) {
        // If a device user explicitly signs in as an anonymous user,
        // then we can safely assume she wants to play as a new player.
        // Set the onboarding state to false to go through it again.
        OnboardingStateManager.shared.setOnboardingCompletedState(state: false)
        handleAfterSignIn(user: user)
    }
    
    func didCompleteSignIn(with user: User, providerIDs: [String]) {
        FirebaseHelper.checkPlayerExists(userID: user.uid) { [weak self] exists in
            // An existing player doesn't need to onboard again.
            OnboardingStateManager.shared.setOnboardingCompletedState(state: exists)
            self?.handleAfterSignIn(user: user)
        }
    }
}
