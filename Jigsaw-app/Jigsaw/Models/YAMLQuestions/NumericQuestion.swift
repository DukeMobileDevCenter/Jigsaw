//
//  NumericQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct NumericQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let unit: String
    let minValue: Double
    let maxValue: Double
    let correctMinValue: Double
    let correctMaxValue: Double
    let isOptional: Bool
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String,
            let unit = data["unit"] as? String,
            let minValue = data["minValue"] as? Double,
            let maxValue = data["maxValue"] as? Double,
            let correctMinValue = data["correctMinValue"] as? Double,
            let correctMaxValue = data["correctMaxValue"] as? Double,
            let isOptional = data["isOptional"] as? Bool else { return nil }
        
        self.questionType = .numeric
        self.title = title
        self.prompt = prompt
        self.isOptional = isOptional
        self.unit = unit
        self.minValue = minValue
        self.maxValue = maxValue
        self.correctMinValue = correctMinValue
        self.correctMaxValue = correctMaxValue
    }
}
