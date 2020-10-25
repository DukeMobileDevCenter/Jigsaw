//
//  BooleanQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct BooleanQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let trueDescription: String
    let falseDescription: String
    let correctAnswer: Bool
    let isOptional: Bool
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String,
            let trueDescription = data["trueDescription"] as? String,
            let falseDescription = data["falseDescription"] as? String,
            let correctAnswer = data["correctAnswer"] as? Bool,
            let isOptional = data["isOptional"] as? Bool else { return nil }
        
        self.questionType = .boolean
        self.title = title
        self.prompt = prompt
        self.isOptional = isOptional
        self.trueDescription = trueDescription
        self.falseDescription = falseDescription
        self.correctAnswer = correctAnswer
    }
}
