//
//  QuestionType.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum QuestionType: String, Codable, CaseIterable {
    case instruction = "INSTRUCTION"
    case singleChoice = "SINGLE CHOICE"
    case multipleChoice = "MULTIPLE CHOICE"
    case numeric = "NUMERIC"
    case scale = "SCALE"
    case boolean = "BOOLEAN"
    case unknown = "UNKNOWN"
}
