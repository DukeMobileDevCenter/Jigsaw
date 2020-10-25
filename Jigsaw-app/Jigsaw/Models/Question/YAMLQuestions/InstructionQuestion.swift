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
    
    init?(data: [String: Any]) {
        guard let title = data["title"] as? String,
            let prompt = data["prompt"] as? String else { return nil }
        self.questionType = .instruction
        self.title = title
        self.prompt = prompt
        // An instruction step is default to non-optional.
        self.isOptional = false
    }
}
