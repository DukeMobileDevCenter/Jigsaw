//
//  QuestionEssentialProperty.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

protocol QuestionEssentialProperty {
    var title: String { get }
    var prompt: String { get }
    var isOptional: Bool { get }
}