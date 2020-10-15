//
//  TeamRanking.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/14/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct TeamRanking: Codable, CustomStringConvertible {
    let teamName: String
    let playerIDs: [String]
    
    let gameName: String
    let score: Double
    
    let playedDate: Date
    
    var description: String {
        return "On \(playedDate.description), players \(playerIDs) played game \(gameName).\n Average game score in the game is \(score * 100)"
    }
    
    var isMyTeam: Bool {
        playerIDs.contains(Profiles.userID)
    }
}
