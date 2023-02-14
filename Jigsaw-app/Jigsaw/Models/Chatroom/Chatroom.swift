//
//  Chatroom.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import FirebaseFirestore

struct Chatroom: Codable {
    /// The unique identifier of the chatroom.
    let id: String?
    /// The name or title of the chatroom, should be decided by the game.
    let name: String
    /// The players in current chatroom.
    let playerIDs: [String]?
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        if let playerIDs = data["playerIDs"] as? [String] {
            self.playerIDs = playerIDs
        } else {
            self.playerIDs = nil
        }
    }
    
    init?(document: DocumentSnapshot) {
        guard let data = document.data(), let name = data["name"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.name = name
        if let playerIDs = data["playerIDs"] as? [String] {
            self.playerIDs = playerIDs
        } else {
            self.playerIDs = nil
        }
    }
    
    init() {
        self.id = UUID().uuidString
        self.name = "Demo Chatroom"
        self.playerIDs = nil
    }
}

extension Chatroom: Comparable {
    static func == (lhs: Chatroom, rhs: Chatroom) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Chatroom, rhs: Chatroom) -> Bool {
        return lhs.name < rhs.name
    }
}
