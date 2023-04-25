//
//  AnswerCategory.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum AnswerCategory: String, CaseIterable, Codable {
    case correct
    case skipped
    case incorrect
    case unknown
    
    var label: String {
        switch self {
        case .correct:
            return Strings.AnswerCategory.AnswerCategory.Label.correct
        case .skipped:
            return Strings.AnswerCategory.AnswerCategory.Label.skipped
        case .incorrect:
            return Strings.AnswerCategory.AnswerCategory.Label.incorrect
        case .unknown:
            return Strings.AnswerCategory.AnswerCategory.Label.unknown
        }
    }
}
