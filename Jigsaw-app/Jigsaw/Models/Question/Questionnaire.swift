//
//  Questionnaire.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

/// Questionnaire is [Question], i.e. an array of questions.
/// - Note: Since we have 6 types of questions now, a questionnaire should not be
///         an array of `Any`. Instead it is an array of objects that all conform to a
///         protocol, which in this case is `QuestionEssentialProperty`.
typealias Questionnaire = [QuestionEssentialProperty]
