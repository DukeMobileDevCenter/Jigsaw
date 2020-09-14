//
//  ProfileViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Eureka
import ViewRow
import FirebaseFirestore
import FirebaseUI

class ProfileViewController: FormViewController {
    // Load from firebase to fill in user info.
    private let database = Firestore.firestore()
    private var authUI: FUIAuth!
    // During onboarding, the form cannot be filled without player info.
    // In this case, load the form when the view is appearing.
    private var shouldLoadFormForTheFirstTime = true
    
    private let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    private let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    
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
    
    private func updatePlayerDisplayName(name: String) {
        database.collection("Players").document(Profiles.userID).updateData(["displayName": name]) { [weak self] error in
            guard let self = self else { return }
            if let error = error {
                print("❌ Error updating document: \(error)")
            } else {
                let playerJigsawPiece = JigsawPiece(rawValue: name)!
                self.profileHeaderRow.cell.view?.nameLabel.text = playerJigsawPiece.label
                self.profileHeaderRow.cell.view?.avatarImageView.setImage(UIImage(named: playerJigsawPiece.bundleName)!)
            }
        }
    }
    
    @objc
    private func loadPlayerProfile() {
        // Get player info from remote.
        database.collection("Players").document(Profiles.userID).getDocument { [weak self] document, error in
            guard let self = self else { return }
            // Dismiss the refresh control.
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
            if let error = error {
                self.presentAlert(error: error)
                return
            }
            guard let document = document, document.exists else {
                // Impossible to come here.
                self.presentAlert(title: "❌ Error: player doesn't exist.")
                return
            }
            do {
                if let currentPlayer = try document.data(as: Player.self) {
                    Profiles.displayName = currentPlayer.displayName
                    Profiles.jigsawValue = currentPlayer.jigsawValue
                    Profiles.currentPlayer = currentPlayer
                    print("✅ Player info loaded,", Profiles().description)
                }
            } catch {
                self.presentAlert(error: error)
            }
        }
    }
    
    private var profileHeaderView: ProfileHeaderView {
        let playerJigsawPiece = JigsawPiece(rawValue: Profiles.displayName)!
        let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
        view.setView(name: playerJigsawPiece.label, avatarFileName: playerJigsawPiece.bundleName)
        // view.setView(name: Profiles.displayName, avatarURL: Profiles.currentPlayer.userID.wavatarURL)
        let user = Auth.auth().currentUser!
        let providerIDs = user.providerData.map { $0.providerID }
        // Load provider icons
        view.googleIconView.tintColor = providerIDs.contains(GoogleAuthProviderID) ? .systemRed : .secondaryLabel
        view.githubIconView.tintColor = providerIDs.contains(GitHubAuthProviderID) ? .systemPurple : .secondaryLabel
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
    
    private var jigsawPieceRow: ActionSheetRow<String> {
        ActionSheetRow<String> { row in
            row.title = "Jigsaw piece"
            row.value = Profiles.displayName
            row.selectorTitle = "Pick a puzzle piece as your nickname."
            row.options = JigsawPiece.allCases.map { $0.rawValue }
        }.cellUpdate { [weak self] _, row in
            if let name = row.value {
                self?.updatePlayerDisplayName(name: name)
            }
        }
    }
    
    private func createForm() {
        form
        +++ Section("Profile")
        <<< profileHeaderRow
        +++ Section(header: "Basic Information", footer: "Blah blah blah")
        <<< jigsawPieceRow
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
        +++ Section("\(appName!) Version \(versionNumber!) build \(buildNumber!)")
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
            Auth.auth().signIn(with: credential) { _, error in
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
