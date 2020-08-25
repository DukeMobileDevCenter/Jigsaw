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
}
