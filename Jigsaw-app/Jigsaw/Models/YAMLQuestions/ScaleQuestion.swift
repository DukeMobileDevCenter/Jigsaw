//
//  ScaleQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct ScaleQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let minDescription: String
    let maxDescription: String
    let minValue: Int
    let maxValue: Int
    let defaultValue: Int
    let step: Int
    let correctMinValue: Int
    let correctMaxValue: Int
    let isOptional: Bool
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String,
            let minDescription = data["minDescription"] as? String,
            let maxDescription = data["maxDescription"] as? String,
            let minValue = data["minValue"] as? Int,
            let maxValue = data["maxValue"] as? Int,
            let defaultValue = data["defaultValue"] as? Int,
            let step = data["step"] as? Int,
            let correctMinValue = data["correctMinValue"] as? Int,
            let correctMaxValue = data["correctMaxValue"] as? Int,
            let isOptional = data["isOptional"] as? Bool else { return nil }
        
        self.questionType = .scale
        self.title = title
        self.prompt = prompt
        self.isOptional = isOptional
        self.minDescription = minDescription
        self.maxDescription = maxDescription
        self.defaultValue = defaultValue
        self.step = step
        self.minValue = minValue
        self.maxValue = maxValue
        self.correctMinValue = correctMinValue
        self.correctMaxValue = correctMaxValue
    }
}
