//
//  DemographicsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/11/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Eureka
//import ResearchKit

class DemographicsViewController: FormViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Demographics"
        
        let ageRules: RuleSet<Int> = {
            var rules = RuleSet<Int>()
            rules.add(rule: RuleGreaterOrEqualThan(min: 1, msg: "Age must be greater than 1"))
            rules.add(rule: RuleSmallerThan(max: 130, msg: "Don't pretend to be too old!"))
            return rules
        }()
        
        form
        +++ Section(header: "Demographics", footer: "Blah blah blah")
        <<< IntRow { row in
            row.title = "Age"
            row.placeholder = "Tell us your age"
            row.add(ruleSet: ageRules)
            row.validationOptions = .validatesOnBlur
        }.cellUpdate { [weak self] cell, row in
            if !row.isValid {
                cell.titleLabel?.textColor = .systemRed
                self?.presentAlert(title: "Invalid input", message: "The value you entered is invalid!")
                row.value = nil
            }
        }
        <<< ActionSheetRow<String> {
            $0.title = "Gender"
            $0.selectorTitle = "Provide your gender"
            $0.options = Genders.allCases.map { $0.rawValue }
        }
        <<< ActionSheetRow<String> {
            $0.title = "Education"
            $0.selectorTitle = "Provide your education"
            $0.options = EducationLevels.allCases.map { $0.rawValue }
        }
        <<< ActionSheetRow<String> {
            $0.title = "Ethnicity"
            $0.selectorTitle = "Provide your ethnic group/identity"
            $0.options = Ethnicities.allCases.map { $0.rawValue }
        }
    }
}
