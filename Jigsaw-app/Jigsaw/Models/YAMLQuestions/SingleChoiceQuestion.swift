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
}
