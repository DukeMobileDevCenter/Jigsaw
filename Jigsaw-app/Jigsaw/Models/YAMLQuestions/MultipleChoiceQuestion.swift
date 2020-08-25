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
}
