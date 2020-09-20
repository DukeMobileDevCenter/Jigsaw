//
//  FirebaseConstants.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore

class FirebaseConstants: NSObject {
    // Singleton of the class.
    static let shared = FirebaseConstants()
    
    static let database = Firestore.firestore()
    
    let chatrooms = FirebaseConstants.database.collection("Chatrooms")
    let games = FirebaseConstants.database.collection("Games")
    let players = FirebaseConstants.database.collection("Players")
    let queues = FirebaseConstants.database.collection("Queues")
    let gamegroups = FirebaseConstants.database.collection("GameGroups")
}
