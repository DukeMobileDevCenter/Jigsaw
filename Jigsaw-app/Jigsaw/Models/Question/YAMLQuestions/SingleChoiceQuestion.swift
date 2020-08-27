//
//  SingleChoiceQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct SingleChoiceQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let choices: [String]
    let correctAnswer: String
    let isOptional: Bool
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String,
            let choices = data["choices"] as? [String],
            let correctAnswer = data["correctAnswer"] as? String,
            let isOptional = data["isOptional"] as? Bool else { return nil }
        
        self.questionType = .singleChoice
        self.title = title
        self.prompt = prompt
        self.isOptional = isOptional
        self.choices = choices
        self.correctAnswer = correctAnswer
    }
}
