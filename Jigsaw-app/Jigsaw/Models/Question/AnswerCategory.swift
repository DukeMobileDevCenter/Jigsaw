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
            return "Correct"
        case .skipped:
            return "Skipped"
        case .incorrect:
            return "Incorrect"
        case .unknown:
            return "Unknown"
        }
    }
}
