//
//  GameGroup.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/15/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct GameGroup: Codable {
    let id: String?
    let gameName: String
    let chatroomID: String
    let createdDate: Date
    var chatroomReadyUserIDs: [String]
    var roomAttemptedUserIDs: [String]
    var roomFinishedUserIDs: [String]
    var allRoomsFinishedUserScores: [String]
    /// An array of player's userIDs.
    let group1: [String]
    /// An array of player's userIDs.
    let group2: [String]
    
    init(id: String, group: GameGroup) {
        self.id = id
        self.gameName = group.gameName
        self.chatroomID = group.chatroomID
        self.createdDate = group.createdDate
        self.chatroomReadyUserIDs = group.chatroomReadyUserIDs
        self.roomAttemptedUserIDs = group.roomAttemptedUserIDs
        self.roomFinishedUserIDs = group.roomFinishedUserIDs
        self.allRoomsFinishedUserScores = group.allRoomsFinishedUserScores
        self.group1 = group.group1
        self.group2 = group.group2
    }
    
    /// Empty GameGroup for Demo Game
//    init() {
//        
//    }
    
    /// A sorted array of all players' IDs in current game group.
    /// - Note: The count of all players can be 2 or 4.
    var allPlayersUserIDs: [String] {
        (group1 + group2).sorted()
    }
    
    /// Check which group is the player in.
    ///
    /// - Parameter userID: The user ID of the player.
    /// - Returns: Return 1 or 2 if player in subgroup 1 or subgroup 2, or return nil if the player is not in current game group.
    func whichGroupContains(userID: String) -> Int? {
        if group1.contains(userID) {
            return 1
        } else if group2.contains(userID) {
            return 2
        }
        return nil
    }
    
    func userScoreString(userID: String, score: Double) -> String {
        return userID + "@" + String(format: "%.6f", score)
    }
}
