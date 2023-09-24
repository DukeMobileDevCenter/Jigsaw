//
//  FirebaseConstants.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

enum FirebaseConstants {
    static let database = Firestore.firestore()
    static let storage = Storage.storage()
    static let auth = Auth.auth()
    
    static let chatrooms = database.collection("Chatrooms")
    static let players = database.collection("Players")
    static let queues = database.collection("Queues")
    static let gamegroups = database.collection("GameGroups")
    /// A reference to the collection of team ranking stats.
    static let teamRankings = database.collection("TeamRankings")
    static let reportedPlayers = database.collection("ReportedPlayers")
    static let reportedChatrooms = database.collection("ReportedChatrooms")
    
    static let gamesStorage = storage.reference(withPath: "Games")
    static let chatroomStorage = storage.reference(withPath: "Chatrooms")
    
    static func chatroomMessagesRef(chatroomID: String) -> CollectionReference {
        database.collection(["Chatrooms", chatroomID, "messages"].joined(separator: "/"))
    }
    
    static func reporteChatroomMessagesRef(chatroomID: String) -> CollectionReference{
        database.collection(["ReportedChatrooms", chatroomID, "messages"].joined(separator: "/"))
    }
    
    static func playerGameHistoryRef(userID: String) -> CollectionReference {
        database.collection(["Players", userID, "gameHistory"].joined(separator: "/"))
    }
    
    static func gameQueueRef(gameName: String, queueType: PlayersQueue) -> CollectionReference {
        database.collection(["Queues", gameName, queueType.rawValue].joined(separator: "/"))
    }
}
