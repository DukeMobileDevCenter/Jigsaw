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

class ProfileViewController: FormViewController {
    // Load from firebase to fill in user info.
    private let database = Firestore.firestore()
    // During onboarding, the form cannot be filled without player info.
    // In this case, load the form when the view is appearing.
    private var shouldLoadFormForTheFirstTime = true
    
    private let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as? String
    private let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    private let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    
    override func viewDidLoad() {
        // Override the tableview appearance.
        loadInsetGroupedTableView()
        super.viewDidLoad()
        configureRefreshControl()
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
    
    private func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadPlayerProfile), for: .valueChanged)
    }
    
    private func updatePlayerDisplayName(name: String) {
        database.collection("Players").document(Profiles.userID).updateData(["displayName": name]) { [weak self] error in
            if let error = error {
                print("❌ Error updating document: \(error)")
                return
            } else {
                self?.profileHeaderRow.cell.view?.nameLabel.text = name
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
        let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
        view.setView(name: Profiles.displayName, avatarURL: Profiles.currentPlayer.userID.wavatarURL)
        return view
    }
    
    private lazy var profileHeaderRow: ViewRow<ProfileHeaderView> = {
        ViewRow<ProfileHeaderView>("view")
        .cellSetup { cell, _ in
            //  Construct the view
            cell.view = self.profileHeaderView
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.presentAlert(title: "More to add here", message: "Change avatar feature is on the way!")
            }
        }
    }()
    
    private var displayNameRow: NameRow {
        let displayNameRules: RuleSet<String> = {
            var rules = RuleSet<String>()
            rules.add(rule: RuleMinLength(minLength: 3, msg: "Display name must be longer than 3 characters."))
            rules.add(rule: RuleMaxLength(maxLength: 10, msg: "Display name must be shorter than 10 characters."))
            return rules
        }()
        
        return NameRow { row in
            row.title = "Display name"
            row.placeholder = "Change your nickname"
            row.value = Profiles.displayName
            row.add(ruleSet: displayNameRules)
            row.validationOptions = .validatesOnBlur
        }.cellUpdate { [weak self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
                self?.presentAlert(title: "Invalid input", message: "The value you entered is invalid!")
                row.value = Profiles.displayName
            } else {
                if let name = row.value {
                    self?.updatePlayerDisplayName(name: name)
                }
            }
        }
    }
    
    private func createForm() {
        form
        +++ Section("Profile")
        <<< profileHeaderRow
        +++ Section(header: "Basic Information", footer: "Blah blah blah")
        <<< displayNameRow
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
