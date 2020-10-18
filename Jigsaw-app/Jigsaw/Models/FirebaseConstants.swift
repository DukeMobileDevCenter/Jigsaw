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

class FirebaseConstants: NSObject {
    // Singleton of the class.
    static let shared = FirebaseConstants()
    
    static let database = Firestore.firestore()
    static let storage = Storage.storage()
    static let auth = Auth.auth()
    
    let chatrooms = database.collection("Chatrooms")
    let players = database.collection("Players")
    let queues = database.collection("Queues")
    let gamegroups = database.collection("GameGroups")
    /// A collection of team ranking stats.
    let teamRankings = database.collection("TeamRankings")
    
    let gamesStorage = storage.reference(withPath: "Games")
    let chatroomStorage = storage.reference(withPath: "Chatrooms")
    
    static func chatroomMessagesRef(chatroomID: String) -> CollectionReference {
        database.collection(["Chatrooms", chatroomID, "messages"].joined(separator: "/"))
    }
    
    static func playerGameHistoryRef(userID: String) -> CollectionReference {
        database.collection(["Players", userID, "gameHistory"].joined(separator: "/"))
    }
    
    static func gameQueueRef(gameName: String, queueType: PlayersQueue) -> CollectionReference {
        database.collection(["Queues", gameName, queueType.rawValue].joined(separator: "/"))
    }
}
