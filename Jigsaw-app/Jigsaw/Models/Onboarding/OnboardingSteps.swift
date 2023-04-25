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
        informedConsentInstructionStep.title = Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.title
        informedConsentInstructionStep.detailText = Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.detailText
        informedConsentInstructionStep.iconImage = UIImage(systemName: "doc.plaintext")
        let infoItem = ORKBodyItem(
            text: Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.InfoItem.text,
            detailText: nil,
            image: UIImage(systemName: "info"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let chatItem = ORKBodyItem(
            text: Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.ChatItem.text,
            detailText: nil,
            image: UIImage(systemName: "bubble.left.and.bubble.right"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let quizItem = ORKBodyItem(
            text: Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.QuizItem.text,
            detailText: nil,
            image: UIImage(systemName: "checkmark.rectangle"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let retryItem = ORKBodyItem(
            text: Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.RetryItem.text,
            detailText: nil,
            image: UIImage(systemName: "repeat"),
            learnMoreItem: nil,
            bodyItemStyle: .image
        )
        let rankingItem = ORKBodyItem(
            text: Strings.OnboardingSteps.OnboardingSteps.InformedConsentInstructionStep.RankingItem.text,
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
            title: Strings.OnboardingSteps.OnboardingSteps.PoliticalSliderStep.PoliticalSliderStep.title,
            question: Strings.OnboardingSteps.OnboardingSteps.PoliticalSliderStep.PoliticalSliderStep.question,
            answer: sliderAnswerFormat
        )
        politicalSliderStep.isOptional = false
        return politicalSliderStep
    }()
    
    static let completionStep: ORKCompletionStep = {
        let completionStep = ORKCompletionStep(identifier: "CompletionStep")
        completionStep.title = Strings.OnboardingSteps.OnboardingSteps.CompletionStep.CompletionStep.title
        completionStep.detailText = Strings.OnboardingSteps.OnboardingSteps.CompletionStep.CompletionStep.detailText
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
