//
//  FirebaseHelper.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/26/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

enum FirebaseHelper {
    /// Check if a player exists in the Players collection.
    ///
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: The closure to pass back if a player exists.
    ///   - playerExists: True for existing player, False for not exist.
    static func checkPlayerExists(userID: String, completion: @escaping (_ playerExists: Bool) -> Void) {
        // Get player info from remote.
        FirebaseConstants.shared.players.document(userID).getDocument { document, _ in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Get a player from Players collection.
    ///
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: Optional player struct and error.
    static func getPlayer(userID: String, completion: @escaping (Player?, Error?) -> Void) {
        // Get player info from remote.
        FirebaseConstants.shared.players.document(userID).getDocument { document, error in
            if let error = error {
                completion(nil, error)
            } else if let document = document, document.exists {
                do {
                    if let currentPlayer = try document.data(as: Player.self) {
                        completion(currentPlayer, nil)
                    }
                } catch {
                    completion(nil, error)
                }
            }
        }
    }
    
    /// Set/Update a player from local struct.
    ///
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - player: A Player struct created locally for the new player info.
    static func setPlayer(userID: String, player: Player) {
        try? FirebaseConstants.shared.players.document(userID).setData(from: player)
    }
    
    /// Load game history records for a player.
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: A closure that passes back an array of `GameHistory`.
    static func getGameHistory(userID: String, completion: @escaping ([GameHistory]?, Error?) -> Void) {
        let historyRef = FirebaseConstants.database.collection(["Players", userID, "gameHistory"].joined(separator: "/"))
        var gameHistories: [GameHistory] = []
        historyRef.getDocuments { querySnapshot, error in
            if let historyRecords = querySnapshot {
                for gameHistory in historyRecords.documents {
                    if let history = try? gameHistory.data(as: GameHistory.self) {
                        gameHistories.append(history)
                    }
                }
                completion(gameHistories, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
}
