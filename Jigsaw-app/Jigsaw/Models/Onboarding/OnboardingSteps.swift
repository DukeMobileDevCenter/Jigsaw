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

/// DEMO: Localize strings
///        instructionStep.title = "Welcome to Jigsaw Escape!"
///        instructionStep.detailText = "In Jigsaw Escape, you will play interactive games and learn about opposing stances on important and polarizing issues. First, let's get you on board!"
        instructionStep.title = Strings.Onboarding.Instruction.title
        instructionStep.detailText = Strings.Onboarding.Instruction.detailText

        instructionStep.image = UIImage(named: "onboarding_welcome")!
        instructionStep.imageContentMode = .scaleAspectFill
        return instructionStep
    }()
    
    static let informedConsentInstructionStep: ORKInstructionStep = {
        let informedConsentInstructionStep = ORKInstructionStep(identifier: "ConsentStepIdentifier")
        informedConsentInstructionStep.title = "Before We Start"
        informedConsentInstructionStep.detailText = "The goal of this game is to escape from a series of rooms by cooperating with your team in information-gathering tasks about a controversial political issue.\n"
        informedConsentInstructionStep.iconImage = UIImage(systemName: "doc.plaintext")
        let infoItem = ORKBodyItem(
            text: "Each member of your team will receive crucial pieces of information about common arguments for positions on the issue.  Each team member will receive bits of information that others do not have.",
            detailText: nil,
            image: UIImage(systemName: "info"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let chatItem = ORKBodyItem(
            text: "You will then chat as a team to share the information that each team member has seen.",
            detailText: nil,
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let quizItem = ORKBodyItem(
            text: "After chatting, each member of your team  will separately take a short quiz covering all the information gathered and shared by all of your team members.",
            detailText: nil,
            image: UIImage(systemName: "checkmark.rectangle"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let retryItem = ORKBodyItem(
            text: "If everyone on your team passes the quiz, then your whole team escapes that room---hurrah!---and you can go on to the next room. If your team does not all pass the quiz, then you will have a chance to go back into the chat to discuss the questions that were missed. Then your team will have another chance to escape the room by each team member passing a quiz on the same quotations.",
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
/*
 FileName.ClassName.Variable.Attribute
 //FIlename1
 
 x constants in Localizable.strings
 
 Onboarding
 Onboarding.x.x.work
 */
