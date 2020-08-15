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

class ProfileViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        createForm()
    }
    
    func createForm() {
        form +++ Section("Profile")
        <<< ViewRow<ProfileHeaderView>("view")
        .cellSetup { cell, _ in
            //  Construct the view
            let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
            view.setView(name: Profiles.displayName, avatarURL: Profiles.currentPlayer.userID.gravatarURL)
            cell.view = view
        }
        .onCellSelection { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.presentAlert(title: "More to add here", message: "Change avatar feature is on the way!")
            }
        }
        +++ Section(header: "Basic information", footer: "Blah blah blah")
        <<< NameRow { row in
            row.title = "Display name"
            row.placeholder = "Change your nickname"
            row.value = Profiles.displayName
        }
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
            row.presentationMode = .show(controllerProvider: ControllerProvider.callback { return DemographicsViewController() }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) })
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
