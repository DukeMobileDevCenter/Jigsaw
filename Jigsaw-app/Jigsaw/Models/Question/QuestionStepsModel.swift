//
//  QuestionStepsModel.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

enum QuestionStepsModel {
    static func instructionStep(question: InstructionQuestion) -> ORKStep {
        let instructionStep = ORKInstructionStep(identifier: question.title)
        instructionStep.title = question.title
        instructionStep.text = question.prompt
        return instructionStep
    }
    
    static func multipleChoiceStep(question: MultipleChoiceQuestion) -> ORKStep {
        let questionStepTitle = question.title
        let textChoices = question.choices.map { ORKTextChoice(text: $0, value: $0 as NSString) }
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: textChoices)
        let questionStep = ORKQuestionStep(identifier: question.title, title: questionStepTitle, question: question.prompt, answer: answerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
    
    static func singleChoiceStep(question: SingleChoiceQuestion) -> ORKStep {
        let questionStepTitle = question.title
        let textChoices = question.choices.map { ORKTextChoice(text: $0, value: $0 as NSString) }
        let answerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoices)
        let questionStep = ORKQuestionStep(identifier: question.title, title: questionStepTitle, question: question.prompt, answer: answerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
    
    static func booleanStep(question: BooleanQuestion) -> ORKStep {
        let questionStepTitle = question.title
        let answerFormat = ORKAnswerFormat.booleanAnswerFormat(withYesString: question.trueDescription, noString: question.falseDescription)
        let questionStep = ORKQuestionStep(identifier: question.title, title: questionStepTitle, question: question.prompt, answer: answerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
    
    static func numericStep(question: NumericQuestion) -> ORKStep {
        let numericAnswerFormat = ORKNumericAnswerFormat(style: .decimal, unit: question.unit)
        numericAnswerFormat.minimum = NSNumber(value: question.minValue)
        numericAnswerFormat.maximum = NSNumber(value: question.maxValue)
        let questionStep = ORKQuestionStep(identifier: question.title, title: question.title, question: question.prompt, answer: numericAnswerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
    
    static func scaleStep(question: ScaleQuestion) -> ORKStep {
        let scaleAnswerFormat = ORKScaleAnswerFormat(
            maximumValue: question.maxValue,
            minimumValue: question.minValue,
            defaultValue: question.defaultValue,
            step: question.step,
            vertical: true,
            maximumValueDescription: question.maxDescription,
            minimumValueDescription: question.minDescription
        )
        scaleAnswerFormat.gradientLocations = [0, 0.6, 1]
        scaleAnswerFormat.gradientColors = [.systemBlue, .systemYellow, .systemRed]
        let questionStep = ORKQuestionStep(identifier: question.title, title: question.title, question: question.prompt, answer: scaleAnswerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
}
