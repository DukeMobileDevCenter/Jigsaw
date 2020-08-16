//
//  GameGroup.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/15/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct GameGroup: Codable {
    let gameName: String
    let chatroomID: String
    let createdDate: Date
    var chatroomUserCount: Int
    /// An array of player's userIDs.
    let group1: [String]
    /// An array of player's userIDs.
    let group2: [String]
}
