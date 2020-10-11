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
    let level: Int
    /// Name of the game.
    let gameName: String
    /// Description detail text.
    let detailText: String
    /// Group resource URLs.
    let resourceURLs: [URL]
    /// Group questionnaires.
    let questionnaires: [Questionnaire]
    let category: GameCategory
}
