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
        // Present sign in page and handle auth.
        handlePresentSignInPage()
        // Set the first launch flag to false to avoid calling sign in again.
        isFirstLaunch = false
    }
    
    func handlePresentSignInPage(animated: Bool = false) {
        // An FirebaseAuth object that handles user sign in.
        let auth = FirebaseConstants.auth
        // Present the sign in view controller as the first page.
        let controller = UIStoryboard(name: "SignInViewController", bundle: .main).instantiateInitialViewController() as! SignInViewController
        controller.auth = auth
        controller.signInManagerDelegate = self
        controller.modalPresentationStyle = .fullScreen
        present(controller, animated: animated)
        
        // Check if the user is signed in.
        if let user = FirebaseConstants.auth.currentUser {
            if user.uid != Profiles.userID {
                // Something went wrong. Force user to sign in again.
                do {
                    // Sign out, delete if anonymous, and reset local profile.
                    let isAnonymous = FirebaseConstants.auth.currentUser?.isAnonymous ?? false
                    let userID = FirebaseConstants.auth.currentUser?.uid
                    try auth.signOut()
                    if isAnonymous, let userID = userID {
                        FirebaseHelper.deleteAnonymousPlayer(userID: userID)
                    }
                    Profiles.resetProfiles()
                } catch {
                    presentAlert(error: error)
                }
            } else {
                // User is signed in, dismiss the sign in page.
                controller.dismiss(animated: true) { [weak self] in
                    self?.handleAfterSignIn(user: user)
                }
            }
        }
        // Retain the sign in page when no user is signed in.
    }
    
    private func handleAfterSignIn(user: User) {
        if Profiles.userID != user.uid {
            // A new user signed in.
            Profiles.userID = user.uid
        }
        switch Profiles.onboardingCompleted {
        case true:
            // Existing user, fetch data from remote directly.
            didCompleteOnboarding()
        case false:
            // Newly signed in user.
            let controller = OnboardingViewController(taskRun: nil)
            controller.onboardingManagerDelegate = self
            // Disallow dismiss-by-interactive-swipe-down for iOS 13 and above.
            controller.isModalInPresentation = true
            present(controller, animated: true)
        }
    }
    
    private func setCurrentPlayer(with userID: String) {
        FirebaseHelper.getPlayer(userID: userID) { [weak self] player, error in
            guard let self = self else { return }
            if let currentPlayer = player {
                Profiles.displayName = currentPlayer.displayName
                Profiles.jigsawValue = currentPlayer.jigsawValue
                Profiles.currentPlayer = currentPlayer
                os_log(.info, "Current player's profile: %s", Profiles().description)
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
        Profiles.onboardingCompleted = false
        handleAfterSignIn(user: user)
    }
    
    func didCompleteSignIn(with user: User, providerIDs: [String]) {
        FirebaseHelper.checkPlayerExists(userID: user.uid) { [weak self] exists in
            // An existing player doesn't need to onboard again.
            Profiles.onboardingCompleted = exists
            self?.handleAfterSignIn(user: user)
        }
    }
}
