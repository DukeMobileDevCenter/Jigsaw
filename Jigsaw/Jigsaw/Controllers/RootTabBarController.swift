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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start to load questionnaires from the very first screen.
        QuestionnaireStore.shared.loadQuestionnairesToMemory()
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
        print(Profiles.userID!)
        print(Profiles.displayName!)
        print(Profiles.jigsawValue)
    }
}
