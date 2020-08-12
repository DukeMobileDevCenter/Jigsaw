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
        form
            +++ Section("Profile")
            <<< ViewRow<ProfileHeaderView>("view")
            .cellSetup { cell, _ in
                //  Construct the view
                let gravatarHash = Profiles.currentPlayer.userID.sha256
                let endIndex = gravatarHash.index(gravatarHash.startIndex, offsetBy: 32)
                let avatarURL = URL(string: "https://www.gravatar.com/avatar/\(gravatarHash[..<endIndex])?d=identicon")!
                print(avatarURL.absoluteString)
                let view = Bundle.main.loadNibNamed("ProfileHeaderView", owner: self)?.first as! ProfileHeaderView
                view.setView(name: Profiles.displayName, avatarURL: avatarURL)
                cell.view = view
                cell.view?.backgroundColor = cell.backgroundColor
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
            }
            <<< DateRow { row in
                row.title = "Join date"
                row.value = Profiles.currentPlayer.joinDate
                row.disabled = true
            }
            +++ Section("Demographics")
            <<< ButtonRow {
                $0.title = "Update your demographics"
                $0.presentationMode = .show(controllerProvider: ControllerProvider.callback { return DemographicsViewController() }, onDismiss: { vc in vc.navigationController?.popViewController(animated: true) })
            }
            +++ Section("Game history")
            <<< ButtonRow { row in
                row.title = "Show game history"
            }
    }
}
