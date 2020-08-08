//
//  Chatroom.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import FirebaseFirestore

struct Chatroom {
    let id: String?
    let name: String
    
    init(name: String) {
        self.id = nil
        self.name = name
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        guard let name = data["name"] as? String else {
            return nil
        }
        self.id = document.documentID
        self.name = name
    }
}

extension Chatroom: DatabaseRepresentation {
    var representation: [String: Any] {
        var rep = ["name": name]
        if let id = id {
            rep["id"] = id
        }
        return rep
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
