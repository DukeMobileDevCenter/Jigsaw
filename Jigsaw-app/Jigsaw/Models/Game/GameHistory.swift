//
//  GameHistory.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/29/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct GameHistory: Codable, CustomStringConvertible {
    var description: String {
        return "On \(playedDate.description), players \(allPlayers) played game \(gameName).\n My score in the game is \(score * 100) and stats are \(gameResult)"
    }
    
    let playedDate: Date
    let gameCategory: GameCategory
    let gameName: String
    let allPlayers: [String]  // playerIDs
    let gameResult: [AnswerCategory: Int]
    let score: Double
}
