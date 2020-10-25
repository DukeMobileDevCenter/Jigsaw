//
//  ProfileViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import UIKit
import SafariServices
import ResearchKit
import Eureka
import ViewRow
import FirebaseUI

class ProfileViewController: FormViewController {
    // During onboarding, the form cannot be filled without player info.
    // In this case, load the form when the view is appearing.
    private var shouldLoadFormForTheFirstTime = true
    
    private var uidString: String {
        "uid: " + (FirebaseConstants.auth.currentUser?.uid ?? "nil error")
    }
    
    override func viewDidLoad() {
        // Override the tableview appearance.
        loadInsetGroupedTableView()
        super.viewDidLoad()
        configureRefreshControl()
        
        // Add an observer to monitor changed user ID and reload the table.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loadPlayerProfile),
            name: .userIDChanged,
            object: nil
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldLoadFormForTheFirstTime {
            createForm()
        }
        if let headerRow = form.rowBy(tag: "ProfileHeaderRow") as? ViewRow<ProfileHeaderView>,
           headerRow.section?.footer?.title != uidString {
            // Reload profile if UI and datasource is inconsistent.
            // This typically happen after player switched account.
            loadPlayerProfile()
        }
        shouldLoadFormForTheFirstTime = false
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadPlayerProfile), for: .valueChanged)
    }
    
    @objc
    private func loadPlayerProfile() {
        guard let playerID = Profiles.userID else { return }
        // Get player info from remote.
        FirebaseHelper.getPlayer(userID: playerID) { [weak self] player, error in
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
            // Dismiss the refresh control.
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
                self.reloadRows()
            }
        }
    }
    
    private func reloadRows() {
        // Reload the header part.
        let headerRow = form.rowBy(tag: "ProfileHeaderRow") as! ViewRow<ProfileHeaderView>
        configureHeaderView(view: headerRow.view!)
        headerRow.section?.footer?.title = uidString
        headerRow.section?.reload()
        headerRow.reload()
        // Reload the jigsaw value row.
        let jigsawValueRow = form.rowBy(tag: "JigsawValueRow") as! DecimalRow
        jigsawValueRow.value = Profiles.jigsawValue
        jigsawValueRow.reload()
        // Reload the join date row.
        let joinDateRow = form.rowBy(tag: "JoinDateRow") as! DateRow
        joinDateRow.value = Profiles.currentPlayer.joinDate
        joinDateRow.reload()
    }
    
    private func configureHeaderView(view: ProfileHeaderView) {
        let piece = JigsawPiece.unknown
        view.setView(name: piece.label, avatarFileName: piece.bundleName)
        if let user = FirebaseConstants.auth.currentUser {
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
    }
    
    private var profileHeaderView: ProfileHeaderView {
        let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
        configureHeaderView(view: view)
        return view
    }
    
    private var profileHeaderRow: ViewRow<ProfileHeaderView> {
        let row = ViewRow<ProfileHeaderView>("view")
        .cellSetup { cell, _ in
            // Construct the view
            cell.view = self.profileHeaderView
        }
        row.tag = "ProfileHeaderRow"
        return row
    }
    
    // swiftlint:disable function_body_length
    private func createForm() {
        form
        +++ Section(header: "Profile", footer: uidString)
        <<< profileHeaderRow
        +++ Section(header: "Basic Information", footer: "These values cannot be changed")
        <<< DecimalRow { row in
            row.tag = "JigsawValueRow"
            row.title = "Jigsaw value"
            row.value = Profiles.jigsawValue
            row.disabled = true
        }
        <<< DateRow { row in
            row.tag = "JoinDateRow"
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
        <<< ButtonRow { row in
            row.title = "Provide Feedback"
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async { [weak self] in
                let controller = SFSafariViewController(url: AppConstants.feedbackFormURL)
                self?.present(controller, animated: true)
            }
        }
        
        // Add app info to the end of this page.
        +++ Section("\(AppInfo.appName) app 🧩 Version \(AppInfo.versionNumber) (\(AppInfo.buildNumber))")
    }
    // swiftlint:enable function_body_length
}

// MARK: Firebase Auth and account connection

extension ProfileViewController {
    @IBAction func userAccountBarButtonTapped(_ sender: UIBarButtonItem) {
        // An action sheet for multiple actions.
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        // Connect action.
        if let user = FirebaseConstants.auth.currentUser, let authUI = createFirebaseUI(for: user) {
            // Only add connectAction when it is able to connect.
            let connectAction = UIAlertAction(title: "Connect Online Account", style: .default) { _ in
                // Create an authentication UI if user exists and haven't connect all accounts.
                let authViewController = authUI.authViewController()
                self.show(authViewController, sender: sender)
            }
            alertController.addAction(connectAction)
        }
        // Sign out action.
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            let alert = UIAlertController(
                title: "Be careful",
                message: "Sign out from anonymous account will lose all your data. Please confirm before proceed.",
                preferredStyle: .alert
            )
            let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { _ in
                // Sign out here.
                do {
                    // Sign out, delete if anonymous, and reset local profile.
                    let isAnonymous = FirebaseConstants.auth.currentUser?.isAnonymous ?? false
                    let userID = FirebaseConstants.auth.currentUser?.uid
                    try FirebaseConstants.auth.signOut()
                    if isAnonymous, let userID = userID {
                        FirebaseHelper.deleteAnonymousPlayer(userID: userID)
                    }
                    
                    Profiles.resetProfiles()
                    // Present the sign in page by the root tab bar.
                    let tabBar = self.tabBarController as! RootTabBarController
                    tabBar.handlePresentSignInPage(animated: true)
                } catch {
                    self.presentAlert(error: error)
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(cancelAction)
            alert.addAction(signOutAction)
            alert.preferredAction = cancelAction
            self.present(alert, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(signOutAction)
        alertController.addAction(cancelAction)
        alertController.popoverPresentationController?.barButtonItem = sender
        present(alertController, animated: true)
    }
    
    private func createFirebaseUI(for user: User) -> FUIAuth? {
        // Init Firebase UI.
        let authUI = FUIAuth.defaultAuthUI()!
        
        // Do not create the FUI if already linked to one of the providers.
        let existingProviderIDs = user.providerData.map { $0.providerID }
        if !existingProviderIDs.isEmpty { return nil }
        
        let providers: [FUIAuthProvider] = [
            FUIGoogleAuth(),
            FUIOAuth.appleAuthProvider(),
            FUIOAuth.githubAuthProvider(),
            FUIEmailAuth()
        ]
        
        authUI.providers = providers
        authUI.delegate = self
        authUI.shouldAutoUpgradeAnonymousUsers = true
        return authUI
    }
}

extension ProfileViewController: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith authDataResult: AuthDataResult?, error: Error?) {
        if let error = error as NSError?, error.code == FUIAuthErrorCode.mergeConflict.rawValue {
            // Merge conflict error, discard the anonymous user and login as the existing
            // non-anonymous user.
            guard let credential = error.userInfo[FUIAuthCredentialKey] as? AuthCredential else {
                os_log(.error, "Received merge conflict error without auth credential!")
                return
            }
            FirebaseConstants.auth.signIn(with: credential) { _, error in
                if let error = error as NSError? {
                    os_log(.error, "Failed to re-login: %@", error.localizedDescription)
                    return
                }
                // Handle successful re-login below.
            }
        } else if let error = error {
            // User canceled account linking.
            os_log(.error, "Failed to log in or canceled: %@", error.localizedDescription)
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
