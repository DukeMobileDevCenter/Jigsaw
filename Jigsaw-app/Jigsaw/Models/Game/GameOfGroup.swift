//
//  GameOfGroup.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct GameOfGroup {
    /// Game version.
    let version: String
    /// The level of the game.
    let level: Int
    /// The maximal attempts defined by the game.
    let maxAttempts: Int
    /// ID of the game.
    let gameID: String
    /// Name of the game.
    let gameName: String
    /// Description detail text.
    let detailText: String
    /// Group resource content (markdown).
    let resourceContent: [String]
    /// Group questionnaires.
    let questionnaires: [Questionnaire]
    /// The category/topic of the game.
    let category: GameCategory
}
