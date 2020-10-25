//
//  QuestionEssentialProperty.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

/// A protocol that a question should conform to.
protocol QuestionEssentialProperty {
    var questionType: QuestionType { get }
    var title: String { get }
    var prompt: String { get }
    var isOptional: Bool { get }
}
