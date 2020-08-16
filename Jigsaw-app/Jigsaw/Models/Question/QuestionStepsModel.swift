//
//  QuestionStepsModel.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

enum QuestionStepsModel {
    static func instructionStep(question: Question) -> ORKStep {
        let instructionStep = ORKInstructionStep(identifier: question.title)
        instructionStep.title = question.title
        instructionStep.text = question.prompt
        return instructionStep
    }
    
    static func multipleChoiceStep(question: Question) -> ORKStep {
        let questionStepTitleM = question.title
        var textChoicesM: [ORKTextChoice] = []
        for choice in question.choices {
            textChoicesM.append(ORKTextChoice(text: choice.text, value: choice.value as NSString))
        }
        let answerFormatM: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .multipleChoice, textChoices: textChoicesM)
        let questionStepM = ORKQuestionStep(identifier: question.title, title: questionStepTitleM, question: question.prompt, answer: answerFormatM)
        questionStepM.isOptional = question.isOptional
        return questionStepM
    }
    
    static func singleChoiceStep(question: Question) -> ORKStep {
        let questionStepTitleS = question.title
        var textChoicesS: [ORKTextChoice] = []
        for choice in question.choices {
            textChoicesS.append(ORKTextChoice(text: choice.text, value: choice.value as NSString))
        }
        let answerFormatS: ORKTextChoiceAnswerFormat = ORKAnswerFormat.choiceAnswerFormat(with: .singleChoice, textChoices: textChoicesS)
        let questionStepS = ORKQuestionStep(identifier: question.title, title: questionStepTitleS, question: question.prompt, answer: answerFormatS)
        questionStepS.isOptional = question.isOptional
        return questionStepS
    }
    
    static func numericStep(question: Question) -> ORKStep {
        let custom: String = question.custom
        let customList = custom.components(separatedBy: ",")
        var tempStr = ""
        var tempPair: [String] = []
        
        var unit: String = ""
        var min: NSNumber = 0
        var max: NSNumber = 10
        
        for item in customList {
            tempStr = item.trimmingCharacters(in: .whitespaces)
            tempPair = tempStr.components(separatedBy: ":")
            if tempPair[0] == "unit" {
                unit = tempPair[1].trimmingCharacters(in: .whitespaces)
            } else if tempPair[0] == "range" {
                let t = tempPair[1].components(separatedBy: "-")
                min = NSNumber(value: Int(t[0]) ?? 0)
                max = NSNumber(value: Int(t[1]) ?? 10)
            } else {
                print("debug info: numeric custom str not recognized")
                continue
            }
        }
        let numericAnswerFormat = ORKNumericAnswerFormat(style: .integer, unit: unit)
        numericAnswerFormat.minimum = min
        numericAnswerFormat.maximum = max
        let questionStep = ORKQuestionStep(identifier: question.title, title: question.title, question: question.prompt, answer: numericAnswerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
    
    static func mapStep(question: Question) -> ORKStep {
        let locationAnswerFormat = ORKLocationAnswerFormat()
        locationAnswerFormat.useCurrentLocation = true
        let questionStep = ORKQuestionStep(identifier: question.title, title: question.title, question: question.prompt, answer: locationAnswerFormat)
        
        questionStep.placeholder = NSLocalizedString("Address", comment: "")
        questionStep.isOptional = false
        return questionStep
    }
    
    static func scaleStep(question: Question) -> ORKStep {
        let custom: String = question.custom
        let customList = custom.components(separatedBy: ",")
        var tempStr = ""
        var tempPair: [String] = []
        
        var min: Int = 0
        var max: Int = 10
        var step: Int = 1
        var defaultVal: Int = 5
        var maxDesc: String = ""
        var minDesc: String = ""
        
        for item in customList {
            tempStr = item.trimmingCharacters(in: .whitespaces)
            tempPair = tempStr.components(separatedBy: ":")
            if tempPair[0] == "default" {
                defaultVal = Int(tempPair[1]) ?? 5
            } else if tempPair[0] == "step" {
                step = Int(tempPair[1]) ?? 1
            } else if tempPair[0] == "range" {
                let pair = tempPair[1].components(separatedBy: "-")
                min = Int(pair[0]) ?? 0
                max = Int(pair[1]) ?? 10
            } else if tempPair[0] == "mindesc" {
                minDesc = tempPair[1].trimmingCharacters(in: .whitespaces)
            } else if tempPair[0] == "maxdesc" {
                maxDesc = tempPair[1].trimmingCharacters(in: .whitespaces)
            } else {
                print("debug info: scale custom str not recognized")
                continue
            }
        }
        
        let scaleAnswerFormat = ORKScaleAnswerFormat(maximumValue: max, minimumValue: min, defaultValue: defaultVal, step: step, vertical: true, maximumValueDescription: maxDesc, minimumValueDescription: minDesc)
        scaleAnswerFormat.gradientLocations = [0, 0.6, 1]
        scaleAnswerFormat.gradientColors = [.systemBlue, .systemYellow, .systemRed]
        let questionStep = ORKQuestionStep(identifier: "id-Q6", title: question.title, question: question.prompt, answer: scaleAnswerFormat)
        questionStep.isOptional = question.isOptional
        return questionStep
    }
}
