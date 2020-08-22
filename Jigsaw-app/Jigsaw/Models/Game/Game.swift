//
//  Game.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct Game: Codable {
    // Game version.
    let version: String
    // Name of the game.
    let gameName: String
    // Group 1 resource URL.
    let g1resURL: String
    // Group 2 resource URL.
    let g2resURL: String
    // Group 1 questionnaire.
    let g1Questionnaire: Questionnaire
    // Group 2 questionnaire.
    let g2Questionnaire: Questionnaire
    // Category, used for categorize games and display icon.
    let category: GameCategory
    // Game card background image URL, can also use for styling.
    let backgroundImageURL: URL
}
