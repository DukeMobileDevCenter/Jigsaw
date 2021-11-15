//
//  SignInViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/26/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import ProgressHUD

// FirebaseUI separate modules
import FirebaseAuthUI
import FirebaseOAuthUI
import FirebaseEmailAuthUI
import FirebaseGoogleAuthUI

protocol SignInManagerDelegate: AnyObject {
    func didCompleteSignIn(withAnonymousUser user: User)
    func didCompleteSignIn(with user: User, providerIDs: [String])
}

class SignInViewController: UIViewController {
    /// The sign in button.
    @IBOutlet var signInButton: UIButton! {
        didSet {
            signInButton.titleLabel?.adjustsFontSizeToFitWidth = true
            signInButton.titleLabel?.minimumScaleFactor = 0.5
            signInButton.layer.cornerRadius = 8
        }
    }
    /// The play anonymously button.
    @IBOutlet var playAnonymouslyButton: UIButton! {
        didSet {
            playAnonymouslyButton.layer.cornerRadius = 8
        }
    }
    
    /// A delegate to inform its parent controller after sign in completed.
    weak var signInManagerDelegate: SignInManagerDelegate?
    
    /// An Firebase Auth object passed from the root tab bar controller.
    var auth: Auth!
    
    @IBAction func signInButtonTapped(_ sender: UIButton) {
        let authUI = createFirebaseUI()
        let authViewController = authUI.authViewController()
        show(authViewController, sender: sender)
    }
    
    @IBAction func playAnonymouslyButtonTapped(_ sender: UIButton) {
        let continueAction = UIAlertAction(title: "Continue", style: .default) { _ in
            // Sign in as an anonymous player.
            self.signInAnonymously(auth: self.auth)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let alert = UIAlertController(
            title: "Info",
            message: "Playing anonymously might result in losing game records. Connect to one of your online accounts in your profile later.",
            preferredStyle: .alert
        )
        alert.addAction(cancelAction)
        alert.addAction(continueAction)
        alert.preferredAction = continueAction
        present(alert, animated: true)
    }
    
    private func signInAnonymously(auth: Auth) {
        ProgressHUD.show()
        auth.signInAnonymously { [weak self] result, error in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            if let error = error {
                self.presentAlert(error: error)
                os_log(.error, "Failed to sign in anonymously: %@", error.localizedDescription)
            } else if let result = result {
                let uid = result.user.uid
                if Profiles.userID != uid {
                    os_log(.info, "Sign in as a different anonymous player, old is %s, new is %s", (Profiles.userID ?? "nil"), uid)
                    Profiles.userID = uid
                }
                // Dismiss current view controller.
                self.dismiss(animated: true, completion: nil)
                // Complete the following steps after sign in.
                self.signInManagerDelegate?.didCompleteSignIn(withAnonymousUser: result.user)
            }
        }
    }
    
    /// Create a pre-built Firebase sign in UI.
    ///
    /// - Note: Please read more at [Sign in with a pre-built UI](https://firebase.google.com/docs/auth/ios/firebaseui#sign_in).
    /// - Returns: An `FUIAuth` object to create the sign in view controller.
    private func createFirebaseUI() -> FUIAuth {
        // Init Firebase UI.
        let authUI = FUIAuth.defaultAuthUI()!
        // Assign delegate to receive sign in result.
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(authUI: authUI),
            FUIOAuth.appleAuthProvider(),
            FUIOAuth.githubAuthProvider(),
            FUIEmailAuth()
        ]
        authUI.providers = providers
        return authUI
    }
}

extension SignInViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error {
            // Log an error.
            os_log(.error, "Failed to sign in with one provider: %@", error.localizedDescription)
        } else if let result = authDataResult {
            // Handle successful login below.
            let user = result.user
            let providerIDs = user.providerData.map { $0.providerID }
            // Dismiss current view controller.
            dismiss(animated: true, completion: nil)
            signInManagerDelegate?.didCompleteSignIn(with: user, providerIDs: providerIDs)
        }
    }
}
