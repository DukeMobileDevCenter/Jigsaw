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
}
