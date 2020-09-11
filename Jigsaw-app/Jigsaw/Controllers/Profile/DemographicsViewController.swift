//
//  DemographicsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/11/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Eureka
import FirebaseFirestore

class DemographicsViewController: FormViewController {
    // Load from firebase to fill in user info.
    private let playersDocRef = Firestore.firestore().collection("Players").document(Profiles.userID)
    
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
    
    private var ageRow: IntRow {
        let ageRules: RuleSet<Int> = {
            var rules = RuleSet<Int>()
            rules.add(rule: RuleGreaterOrEqualThan(min: 1, msg: "Age must be greater than 1"))
            rules.add(rule: RuleSmallerThan(max: 130, msg: "Don't pretend to be too old!"))
            return rules
        }()
        
        return IntRow { row in
            row.title = "Age"
            row.tag = "age"
            row.placeholder = "Tell us your age"
            if let age = Profiles.currentPlayer.demographics["age"], age != nil {
                row.value = Int(string: age!)
            }
            row.add(ruleSet: ageRules)
            row.validationOptions = .validatesOnBlur
        }.cellUpdate { [weak self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
                self?.presentAlert(title: "Invalid input", message: "The value you entered is invalid!")
                row.value = nil
            }
        }
    }
    
    private func actionSheetRow(title: String, tag: String, selectorTitle: String, options: [String]) -> ActionSheetRow<String> {
        ActionSheetRow<String> { row in
            row.title = title
            row.tag = tag
            if let value = Profiles.currentPlayer.demographics[tag] {
                row.value = value
            }
            row.selectorTitle = selectorTitle
            row.options = options
        }
    }
    
    private func createForm() {
        form
        +++ Section(header: "Update your demographics here.", footer: "Blah blah blah all the information are confidential.")
        <<< ageRow
        <<< actionSheetRow(title: "Gender", tag: "gender", selectorTitle: "Provide your gender", options: Gender.allCases.map { $0.rawValue })
        <<< actionSheetRow(title: "Education", tag: "education", selectorTitle: "Provide your education", options: EducationLevel.allCases.map { $0.rawValue })
        <<< actionSheetRow(title: "Ethnicity", tag: "ethnicity", selectorTitle: "Provide your ethnic group/identity", options: Ethnicity.allCases.map { $0.rawValue })
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
        let formatter = NumberFormatter()
        var demographicsDictionary = [String: String?]()
        for (key, value) in form.values() {
            if value is Int {
                demographicsDictionary[key] = formatter.string(from: NSNumber(value: value as! Int))
            } else if value is String {
                demographicsDictionary[key] = value as? String
            } else if value == nil {
                demographicsDictionary[key] = nil
            }
        }
        if demographicsDictionary != Profiles.currentPlayer.demographics {
            updatePlayerDemographics(demographics: demographicsDictionary)
        }
    }
}
