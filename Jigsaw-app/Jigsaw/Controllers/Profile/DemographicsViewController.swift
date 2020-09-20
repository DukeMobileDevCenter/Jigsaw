//
//  DemographicsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/11/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Eureka

class DemographicsViewController: FormViewController {
    // Load from firebase to fill in user info.
    private let playersDocRef = FirebaseConstants.shared.players.document(Profiles.userID)
    
    private func updatePlayerDemographics(demographics: [String: String?]) {
        playersDocRef.updateData(["demographics": demographics]) { error in
            if let error = error {
                print("❌ Error updating document: \(error)")
                return
            } else {
                // Only sync up when remote write succeeds.
                Profiles.currentPlayer.demographics = demographics
            }
        }
    }
    
    private func actionSheetRow(title: String, tag: String, selectorTitle: String, options: [String]) -> ActionSheetRow<String> {
        ActionSheetRow<String> { row in
            row.title = title
            row.tag = tag
            if let value = Profiles.currentPlayer.demographics[tag], value != nil {
                switch tag {
                case "age":
                    row.value = AgeGroup(rawValue: value!)?.label
                case "gender":
                    row.value = Gender(rawValue: value!)?.label
                case "education":
                    row.value = EducationLevel(rawValue: value!)?.label
                case "ethnicity":
                    row.value = Ethnicity(rawValue: value!)?.label
                default:
                    break
                }
            }
            row.selectorTitle = selectorTitle
            row.options = options
        }
    }
    
    private func createForm() {
        form
        +++ Section(header: "Update your demographics here.", footer: "Blah blah blah all the information are confidential.")
        <<< actionSheetRow(title: "Age", tag: "age", selectorTitle: "Provide your age group", options: AgeGroup.allCases.map { $0.label })
        <<< actionSheetRow(title: "Gender", tag: "gender", selectorTitle: "How you identify your gender", options: Gender.allCases.map { $0.label })
        <<< actionSheetRow(title: "Education", tag: "education", selectorTitle: "Highest education level so far", options: EducationLevel.allCases.map { $0.label })
        <<< actionSheetRow(title: "Ethnicity", tag: "ethnicity", selectorTitle: "How you identify your ethnic group", options: Ethnicity.allCases.map { $0.label })
    }
    
    override func viewDidLoad() {
        // Override the tableview appearance.
        loadInsetGroupedTableView()
        super.viewDidLoad()
        title = "Demographics"
        createForm()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        var demographicsDictionary = [String: String?]()
        for (key, value) in form.values() {
            guard let valueString = value as? String else { continue }
            switch key {
            case "age":
                demographicsDictionary[key] = AgeGroup(label: valueString)?.rawValue
            case "gender":
                demographicsDictionary[key] = Gender(label: valueString)?.rawValue
            case "education":
                demographicsDictionary[key] = EducationLevel(label: valueString)?.rawValue
            case "ethnicity":
                demographicsDictionary[key] = Ethnicity(label: valueString)?.rawValue
            default:
                demographicsDictionary[key] = nil
            }
        }
        if demographicsDictionary != Profiles.currentPlayer.demographics {
            updatePlayerDemographics(demographics: demographicsDictionary)
        }
    }
}
