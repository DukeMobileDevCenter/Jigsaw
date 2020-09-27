//
//  ProfileViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit
import Eureka
import ViewRow
import FirebaseUI

class ProfileViewController: FormViewController {
    // Firebase UI.
    private var authUI: FUIAuth!
    // During onboarding, the form cannot be filled without player info.
    // In this case, load the form when the view is appearing.
    private var shouldLoadFormForTheFirstTime = true
    
    @IBAction func userAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        let authViewController = authUI.authViewController()
        show(authViewController, sender: sender)
    }
    
    override func viewDidLoad() {
        // Override the tableview appearance.
        loadInsetGroupedTableView()
        super.viewDidLoad()
        configureRefreshControl()
        // Create an authentication UI.
        authUI = createFirebaseUI()
        
        if Profiles.currentPlayer != nil {
            createForm()
            shouldLoadFormForTheFirstTime = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldLoadFormForTheFirstTime {
            createForm()
        }
        shouldLoadFormForTheFirstTime = false
    }
    
    private func createFirebaseUI() -> FUIAuth {
        // Init Firebase UI.
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIEmailAuth()
        ]
        authUI.providers = providers
        authUI.shouldAutoUpgradeAnonymousUsers = true
        return authUI
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadPlayerProfile), for: .valueChanged)
    }
    
    @objc
    private func loadPlayerProfile() {
        // Get player info from remote.
        FirebaseHelper.getPlayer(userID: Profiles.userID) { [weak self] player, error in
            guard let self = self else { return }
            // Dismiss the refresh control.
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
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
    
    private var profileHeaderView: ProfileHeaderView {
        let piece = JigsawPiece.unknown
        let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
        view.setView(name: piece.label, avatarFileName: piece.bundleName)
        if let user = FirebaseConstants.shared.currentUser {
            let providerIDs = user.providerData.map { $0.providerID }
            if let name = user.displayName, let photoURL = user.photoURL {
                // Display account associated avatar for profile page.
                view.setView(name: name, avatarURL: photoURL)
            }
            // Load provider icons
            view.googleIconView.tintColor = providerIDs.contains(GoogleAuthProviderID) ? .systemRed : .secondaryLabel
            view.githubIconView.tintColor = providerIDs.contains(GitHubAuthProviderID) ? .systemPurple : .secondaryLabel
            view.appleIconView.tintColor = providerIDs.contains("apple.com") ? .systemTeal : .secondaryLabel
            view.emailIconView.tintColor = providerIDs.contains(EmailAuthProviderID) ? .systemGreen : .secondaryLabel
        }
        return view
    }
    
    private lazy var profileHeaderRow: ViewRow<ProfileHeaderView> = {
        ViewRow<ProfileHeaderView>("view")
        .cellSetup { cell, _ in
            // Construct the view
            cell.view = self.profileHeaderView
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.presentAlert(title: "More to add here", message: "Change avatar feature is on the way!")
            }
        }
    }()
    
    private func createForm() {
        form
        +++ Section("Profile")
        <<< profileHeaderRow
        +++ Section(header: "Basic Information", footer: "Blah blah blah")
        <<< DecimalRow { row in
            row.title = "Jigsaw value"
            row.value = Profiles.jigsawValue
            row.disabled = true
        }
        <<< DateRow { row in
            row.title = "Join date"
            row.value = Profiles.currentPlayer.joinDate
            row.disabled = true
        }
        +++ Section("Demographics")
        <<< ButtonRow { row in
            row.title = "Update Demographics"
            row.presentationMode = .show(controllerProvider: ControllerProvider.callback {
                let controller = DemographicsViewController()
                controller.hidesBottomBarWhenPushed = true
                return controller
            }, onDismiss: { controller in controller.navigationController?.popViewController(animated: true) })
        }
        +++ Section("Game History")
        <<< ButtonRow { row in
            row.title = "Show Game History"
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.performSegue(withIdentifier: "showGameHistoryTimelineSegue", sender: self)
            }
        }
        +++ Section("Game Instructions")
        <<< ButtonRow { row in
            row.title = "Review Game Instruction"
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async { [weak self] in
                let steps = [OnboardingSteps.informedConsentInstructionStep]
                let task = ORKOrderedTask(identifier: "InstructionTaskInProfile", steps: steps)
                let controller = ORKTaskViewController(task: task, taskRun: nil)
                controller.delegate = self
                self?.present(controller, animated: true)
            }
        }
        // Add app info to the end of this page.
        +++ Section("\(AppInfo.appName) 🧩 Version \(AppInfo.versionNumber) build \(AppInfo.buildNumber)")
    }
}

extension ProfileViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error as NSError?, error.code == FUIAuthErrorCode.mergeConflict.rawValue {
            // Merge conflict error, discard the anonymous user and login as the existing
            // non-anonymous user.
            guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
                print("Received merge conflict error without auth credential!")
                return
            }
            FirebaseConstants.auth.signIn(with: credential) { _, error in
                if let error = error as NSError? {
                    print("Failed to re-login: \(error)")
                    return
                }
                // Handle successful re-login below.
            }
        } else if let error = error {
            // User canceled account linking.
            print("Failed to log in: \(error.localizedDescription)")
        } else if let result = authDataResult {
            // Handle successful login below.
            let user = result.user
            user.providerData.forEach { userInfo in
                print(userInfo.providerID)
            }
        }
    }
}

extension ProfileViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, stepViewControllerWillAppear stepViewController: ORKStepViewController) {
        // Disable cancel button for instruction page
        // Refer to https://github.com/ResearchKit/ResearchKit/issues/1273.
        stepViewController.cancelButtonItem = UIBarButtonItem()
    }
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true)
    }
}
