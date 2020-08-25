//
//  InstructionQuestion.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct InstructionQuestion: Codable, QuestionEssentialProperty {
    let questionType: QuestionType
    let title: String
    let prompt: String
    let isOptional: Bool
}
