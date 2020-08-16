//
//  QuestionType.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

protocol QuestionEssentialProperty {
    var title: String { get }
    var prompt: String { get }
    var isOptional: Bool { get }
}

enum QuestionType: String, Codable {
    case instruction = "INSTRUCTION"
    case multipleChoice = "MULTIPLE CHOICE"
    case singleChoice = "SINGLE CHOICE"
    case numeric = "NUMERIC"
    case map = "MAP"
    case scale = "SCALE"
    case unknown = "UNKNOWN"
}

struct Choice: Codable {
    let text: String
    let value: String
}
