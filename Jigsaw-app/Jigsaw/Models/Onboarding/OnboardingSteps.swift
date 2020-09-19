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
        instructionStep.detailText = "Welcome to [NAME]! Through a series of interactive games, you'll learn about the presidential candidates' stances on important issues ahead of the election. First, let's get you on board!"
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
            image: UIImage(systemName: "checkmark.rectangle"),
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
        completionStep.detailText = "Let's start to explore the world of Jigsaw!"
        return completionStep
    }()
}
