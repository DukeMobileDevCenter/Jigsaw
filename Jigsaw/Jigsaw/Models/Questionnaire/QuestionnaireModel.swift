//
//  QuestionnaireModel.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import ResearchKit

struct Questionnaire: Codable {
    let version: Int
    let questions: [Question]

    init(version: Int, list: [Question]) {
        self.version = version
        self.questions = list
    }
}

struct Question: Codable {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let choices: [Choice]
    let custom: String
    let optional: Bool

    init(questionType: String, title: String, prompt: String, choices: [Choice], custom: String, optional: Bool) {
//        self.questionType = QuestionType(rawValue: questionType)
        
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
        self.optional = optional
    }
}

enum QuestionType: String, Codable {
    case instruction = "INSTRUCTION"
    case multipleChoice = "MULTIPLE CHOICE"
    case singleChoice = "SINGLE CHOICE"
    case numeric = "NUMERIC"
    case map = "MAP"
    case scale = "SCALE"
    case unknown = "UNKNOWN"
}

struct Choice: Codable {
    let text: String
    let value: String

    init(text: String, value: String) {
        self.text = text
        self.value = value
    }
}
