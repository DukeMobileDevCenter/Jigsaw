//
//  TeamRanking.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/14/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct TeamRanking: Codable {
    let teamName: String
    let playerIDs: [String]
    
    let gameName: String
    let score: Double
    
    let playedDate: Date
}
