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
        instructionStep.title = "Welcome"
        instructionStep.detailText = "Welcome to the game of Jigsaw - Political Escape Rooms! We will increase our empathy in the collaboration through these escape rooms. Before we start, there are a few steps that get you onboard. Let's get started!"
        instructionStep.image = UIImage(named: "onboarding_welcome")!
        instructionStep.imageContentMode = .scaleAspectFill
        return instructionStep
    }()
    
    static let informedConsentInstructionStep: ORKInstructionStep = {
        let informedConsentInstructionStep = ORKInstructionStep(identifier: "ConsentStepIdentifier")
        informedConsentInstructionStep.title = "Before We Start"
        informedConsentInstructionStep.detailText = "The goal of this game is to escape from a series of rooms. To do so, you will need to cooperate with your team in information-gathering tasks about a political issue or candidate.\n"
        informedConsentInstructionStep.iconImage = UIImage(systemName: "doc.plaintext")
        let infoItem = ORKBodyItem(
            text: "Each team member will receive a few crucial pieces of information that other team members do not have.",
            detailText: nil,
            image: UIImage(systemName: "info"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let chatItem = ORKBodyItem(
            text: "After receiving your information, you will have a chance to chat with your teammates in order to share your information and learn about theirs.",
            detailText: nil,
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let quizItem = ORKBodyItem(
            text: "After the chat, you will each receive a short quiz covering all the information gathered and shared by all of your team members.",
            detailText: nil,
            image: UIImage(systemName: "text.badge.checkmark"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let retryItem = ORKBodyItem(
            text: "If all members of your team pass the quiz, then you escape that room and go to the next. But if anyone from your team fails the quiz, then you will all be bumped back into a chat to confer about the questions that were missed, and you will have another chance to pass a different quiz and escape on that try.",
            detailText: nil,
            image: UIImage(systemName: "repeat"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let rankingItem = ORKBodyItem(
            text: "Teams will be ranked on how quickly they are able to move through all rooms in this series. Success will require effective communication and cooperation.",
            detailText: nil,
            image: UIImage(systemName: "list.bullet.indent"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        informedConsentInstructionStep.bodyItems = [infoItem, chatItem, quizItem, retryItem, rankingItem]
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
            question: "Please indicate your political orientation on the slider below.",
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
    
    static let completionStep: ORKCompletionStep = {
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "All Done!"
        completionStep.detailText = "Please start to explore the world of Jigsaw."
        return completionStep
    }()
    
//    static let profileStep: ORKFormStep = {
//        // Gender picker
//        var genderTextChoices: [ORKTextChoice] = []
//        for gender in Gender.allCases {
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
