//
//  QuestionType.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum QuestionType: String, Codable, CaseIterable {
    case instruction = Strings.QuestionType.instruction
    case singleChoice = Strings.QuestionType.singleChoice
    case multipleChoice = Strings.QuestionType.multipleChoice
    case numeric = Strings.QuestionType.numeric
    case scale = Strings.QuestionType.scale
    case continuousScale = Strings.QuestionType.continuousScale
    case boolean = Strings.QuestionType.boolean
    case unknown = Strings.QuestionType.unknown
}
