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
    var gameAttemptedUserIDs: [String]
    var gameFinishedUserIDs: [String]
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
        self.gameAttemptedUserIDs = group.gameAttemptedUserIDs
        self.gameFinishedUserIDs = group.gameFinishedUserIDs
        self.group1 = group.group1
        self.group2 = group.group2
    }
    
    var userIDCount: Int {
        group1.count + group2.count
    }
    
    func whichGroupContains(userID: String) -> Int? {
        if group1.contains(userID) {
            return 1
        } else if group2.contains(userID) {
            return 2
        }
        return nil
    }
}
