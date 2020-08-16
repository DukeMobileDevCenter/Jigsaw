//
//  Questionnaire.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import ResearchKit

// Questionnaire is [Question], i.e. an array of questions.
typealias Questionnaire = [Question]

struct Question: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let choices: [Choice]
    let custom: String
    let isOptional: Bool

    init(questionType: String, title: String, prompt: String, choices: [Choice], custom: String, optional: Bool) {
        switch questionType {
        case "INSTRUCTION":
            self.questionType = .instruction
        case "MULTIPLE CHOICE":
            self.questionType = .multipleChoice
        case "SINGLE CHOICE":
            self.questionType = .singleChoice
        case "NUMERIC":
            self.questionType = .numeric
        case "MAP":
            self.questionType = .map
        case "SCALE":
            self.questionType = .scale
        default:
            self.questionType = .unknown
        }
        
        self.title = title
        self.prompt = prompt
        self.choices = choices
        self.custom = custom
        self.isOptional = optional
    }
}
