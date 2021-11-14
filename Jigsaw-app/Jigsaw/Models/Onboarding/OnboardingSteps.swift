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
        instructionStep.detailText = "Welcome to Jigsaw! Through a series of interactive games, you'll learn about different stances on important and polarizing issues. First, let's get you on board!"
        instructionStep.image = UIImage(named: "onboarding_welcome")!
        instructionStep.imageContentMode = .scaleAspectFill
        return instructionStep
    }()
    
    static let informedConsentInstructionStep: ORKInstructionStep = {
        let informedConsentInstructionStep = ORKInstructionStep(identifier: "ConsentStepIdentifier")
        informedConsentInstructionStep.title = "Before We Start"
        informedConsentInstructionStep.detailText = "The goal of this game is to escape from a series of rooms. To do so, you will need to cooperate with your team in information-gathering tasks about a political issue.\n"
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
            image: UIImage(systemName: "checkmark.rectangle"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let retryItem = ORKBodyItem(
            text: "If all members of your team pass the quiz, then you escape that room and go to the next. If you do not all pass the quiz, you will have a chance to go back into the chat and talk as a team about the questions that were missed. Then you will have another chance to escape the room by passing a quiz on the same quotations.",
            detailText: nil,
            image: UIImage(systemName: "repeat"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let rankingItem = ORKBodyItem(
            text: "Teams will be ranked on the percentage of quiz questions that the team gets correct. Ties will be broken by how quickly the team was able to move through all of the rooms in this series.",
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
            title: "Jigsaw Value",
            question: "Please indicate your political orientation on the slider below.",
            answer: sliderAnswerFormat
        )
        politicalSliderStep.isOptional = false
        return politicalSliderStep
    }()
    
    static let completionStep: ORKCompletionStep = {
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = "All Done"
        completionStep.detailText = "Start playing now!"
        return completionStep
    }()
}
