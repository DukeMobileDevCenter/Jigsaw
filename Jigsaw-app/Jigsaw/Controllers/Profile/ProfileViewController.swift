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
    private let playerDocRef = Firestore.firestore().collection("Players").document(Profiles.userID)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRefreshControl()
        createForm()
    }
    
    private func configureRefreshControl() {
        // Add the refresh control to your UIScrollView object.
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(loadPlayerProfile), for: .valueChanged)
    }
    
    private func updatePlayerDisplayName(name: String) {
        playerDocRef.updateData(["displayName": name]) { error in
            if let error = error {
                print("❌ Error updating document: \(error)")
                return
            }
        }
    }
    
    @objc
    private func loadPlayerProfile() {
        // Get player info from remote.
        playerDocRef.getDocument { [weak self] document, error in
            guard let self = self else { return }
            // Reload name label and dismiss the refresh control.
            DispatchQueue.main.async {
                self.profileHeaderRow.cell.view?.nameLabel.text = Profiles.displayName
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
        view.setView(name: Profiles.displayName, avatarURL: Profiles.currentPlayer.userID.gravatarURL)
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
        +++ Section(header: "Basic information", footer: "Blah blah blah")
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
            row.title = "Update your demographics"
            row.presentationMode = .show(controllerProvider: ControllerProvider.callback { DemographicsViewController() }, onDismiss: { controller in controller.navigationController?.popViewController(animated: true) })
        }
        +++ Section("Game history")
        <<< ButtonRow { row in
            row.title = "Show game history"
        }
        .onCellSelection { [weak self] _, _ in
            self?.presentAlert(title: "More to add here", message: "Show game history is on the way!")
        }
    }
}
