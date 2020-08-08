//
//  OnboardingSteps.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

enum OnboardingSteps {
    static let instructionStep: ORKInstructionStep = {
        let instructionStep = ORKInstructionStep(identifier: "InstructionStepIdentifier")
        instructionStep.title = "Welcome!"
        instructionStep.detailText = "Thank you for joining our study. Tap Next to learn more."
        instructionStep.image = UIImage(named: "onboarding_jigsaw")!
        return instructionStep
    }()
    
    static let informedConsentInstructionStep: ORKInstructionStep = {
        let informedConsentInstructionStep = ORKInstructionStep(identifier: "ConsentStepIdentifier")
        informedConsentInstructionStep.title = "Before You Join"
        informedConsentInstructionStep.detailText = "Lorem ipsum"
        informedConsentInstructionStep.iconImage = UIImage(systemName: "doc.plaintext")
        //        informedConsentInstructionStep.image = UIImage(named: "placeholder")!
        let heartBodyItem = ORKBodyItem(
            text: "lorem ipsum",
            detailText: nil,
            image: UIImage(systemName: "heart.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let checkmarkItem = ORKBodyItem(
            text: "lorem ipsum",
            detailText: nil,
            image: UIImage(systemName: "checkmark.circle.fill"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let signatureItem = ORKBodyItem(
            text: "lorem ipsum",
            detailText: nil,
            image: UIImage(systemName: "signature"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        informedConsentInstructionStep.bodyItems = [heartBodyItem, checkmarkItem, signatureItem]
        return informedConsentInstructionStep
    }()
    
    static let politicalSliderStep: ORKQuestionStep = {
        // The key value of the app: political slider value
        let sliderAnswerFormat = ORKContinuousScaleAnswerFormat(
            maximumValue: 1,
            minimumValue: 0,
            defaultValue: 0.5,
            maximumFractionDigits: 2,
            vertical: false,
            maximumValueDescription: "Conservative",
            minimumValueDescription: "Liberal"
        )
        sliderAnswerFormat.shouldHideRanges = true
        sliderAnswerFormat.shouldHideSelectedValueLabel = true
        sliderAnswerFormat.gradientLocations = [0, 0.6, 1]
        sliderAnswerFormat.gradientColors = [.systemBlue, .systemYellow, .systemRed]
        let politicalSliderStep = ORKQuestionStep(
            identifier: "PoliticalSliderStep",
            title: "Jigsaw value",
            question: "Please pick a value to reflect your tendency.",
            answer: sliderAnswerFormat
        )
        politicalSliderStep.isOptional = false
        return politicalSliderStep
    }()
    
    static let profileStep: ORKQuestionStep = {
        // Display name
        let displayNameAnswerFormat = ORKAnswerFormat.textAnswerFormat(withMaximumLength: 10)
        displayNameAnswerFormat.spellCheckingType = .no
        displayNameAnswerFormat.autocapitalizationType = .none
        let step = ORKQuestionStep(identifier: "DisplayNameStep", title: "Display name", question: "Please provide a nickname.", answer: displayNameAnswerFormat)
        return step
    }()
    
//    static let profileStep: ORKFormStep = {
//        // Gender picker
//        var genderTextChoices: [ORKTextChoice] = []
//        for gender in Genders.allCases {
//            let c = ORKTextChoice(text: gender.rawValue, value: gender.rawValue as NSString)
//            genderTextChoices.append(c)
//        }
//        let genderAnswerFormat = ORKAnswerFormat.valuePickerAnswerFormat(with: genderTextChoices)
//        let genderItem = ORKFormItem(identifier: "gender", text: "Gender", answerFormat: genderAnswerFormat, optional: true)
//        genderItem.isOptional = true
//
//        // Age group
//        let ageAnswerFormat = ORKAnswerFormat.integerAnswerFormat(withUnit: "years old")
//        ageAnswerFormat.minimum = 1
//        ageAnswerFormat.maximum = 99
//        let ageItem = ORKFormItem(identifier: "age", text: "Age", answerFormat: ageAnswerFormat, optional: true)
//        ageItem.isOptional = true
//
//        // Display name
//        let displayNameAnswerFormat = ORKAnswerFormat.textAnswerFormat(withMaximumLength: 10)
//        displayNameAnswerFormat.spellCheckingType = .no
//        displayNameAnswerFormat.autocapitalizationType = .none
//        let displayNameItem = ORKFormItem(identifier: "displayName", text: "Display name", detailText: "Your nickname in the app", learnMoreItem: nil, showsProgress: false, answerFormat: displayNameAnswerFormat, tagText: nil, optional: true)
//
//        // Email
//        let emailAnswerFormat = ORKAnswerFormat.emailAnswerFormat()
//        let emailItem = ORKFormItem(identifier: "email", text: "Email Address", answerFormat: emailAnswerFormat, optional: true)
//
//        let formStep = ORKFormStep(
//            identifier: "ProfileStep",
//            title: "Profile info",
//            text: "Tell us more about yourself, skipable."
//        )
//
//        formStep.formItems = [
//            displayNameItem,
//            emailItem,
//            genderItem,
//            ageItem
//        ]
//
//        return formStep
//    }()
}
