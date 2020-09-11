//
//  GameGroup.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/15/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct GameGroup: Codable {
    let gameName: String
    let chatroomID: String
    let createdDate: Date
    var chatroomReadyUserIDs: [String]
    /// An array of player's userIDs.
    let group1: [String]
    /// An array of player's userIDs.
    let group2: [String]
}
