//
//  MultipleChoiceQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct MultipleChoiceQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let choices: [String]
    let correctAnswers: [String]
    let isOptional: Bool
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String,
            let choices = data["choices"] as? [String],
            let correctAnswers = data["correctAnswers"] as? [String],
            let isOptional = data["isOptional"] as? Bool else { return nil }
        
        self.questionType = .multipleChoice
        self.title = title
        self.prompt = prompt
        self.isOptional = isOptional
        self.choices = choices
        self.correctAnswers = correctAnswers
    }
    
    // Demo MultipleChoiceQuestion
    init() {
        self.questionType = .multipleChoice
        self.title = "Sample Multiple Choice"
        self.prompt = "What is the capital of France?"
        self.isOptional = false
        self.choices = ["Paris", "London", "New York"]
        self.correctAnswers = ["Paris", "London", "New York"]
    }
}
