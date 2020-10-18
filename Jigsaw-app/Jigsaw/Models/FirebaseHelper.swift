//
//  FirebaseHelper.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/26/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

enum FirebaseHelper {
    /// Check if a player exists in the Players collection.
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: The closure to pass back if a player exists.
    ///   - playerExists: True for existing player, False for not exist.
    static func checkPlayerExists(userID: String, completion: @escaping (_ playerExists: Bool) -> Void) {
        // Get player info from remote.
        FirebaseConstants.players.document(userID).getDocument { document, _ in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    /// Get a player from Players collection.
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: Optional player struct and error.
    static func getPlayer(userID: String, completion: @escaping (Player?, Error?) -> Void) {
        // Get player info from remote.
        FirebaseConstants.players.document(userID).getDocument { document, error in
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
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - player: A Player struct created locally for the new player info.
    static func setPlayer(userID: String, player: Player) {
        try? FirebaseConstants.players.document(userID).setData(from: player)
    }
    
    /// Delete a user from Players collection.
    ///
    /// - Parameter userID: A user ID, which should have been checked to be anonymous.
    static func deleteAnonymousPlayer(userID: String) {
        FirebaseConstants.players.document(userID).delete()
    }
    
    /// Load game history records for a player.
    /// - Parameters:
    ///   - userID: The user ID of the player.
    ///   - completion: A closure that passes back an array of `GameHistory`.
    static func getGameHistory(userID: String, completion: @escaping ([GameHistory]?, Error?) -> Void) {
        let historyRef = FirebaseConstants.playerGameHistoryRef(userID: userID)
        var gameHistories: [GameHistory] = []
        historyRef.getDocuments { querySnapshot, error in
            if let snapshot = querySnapshot {
                for gameHistory in snapshot.documents {
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
    
    /// Load top 25 team rankings.
    /// - Parameter completion: A closure that passes back an array of `TeamRanking`.
    static func getTeamRankings(completion: @escaping ([TeamRanking]?, Error?) -> Void) {
        let rankingsRef = FirebaseConstants.teamRankings
        var rankings: [TeamRanking] = []
        let query = rankingsRef.order(by: "score", descending: true).limit(to: 25)
        query.getDocuments { querySnapshot, error in
            if let snapshot = querySnapshot {
                for ranking in snapshot.documents {
                    if let rank = try? ranking.data(as: TeamRanking.self) {
                        rankings.append(rank)
                    }
                }
                completion(rankings, nil)
            } else if let error = error {
                completion(nil, error)
            }
        }
    }
    
    /// Delete all the messages from a chatroom's "messages" collection.
    /// - Parameters:
    ///   - chatroomID: The ID of the chatroom.
    ///   - completion: A closure that passes back any error.
    static func deleteMessages(chatroomID: String, completion: @escaping (Error?) -> Void) {
        let messagesRef = FirebaseConstants.chatroomMessagesRef(chatroomID: chatroomID)
        messagesRef.getDocuments { querySnapshot, error in
            if let snapshot = querySnapshot, !snapshot.isEmpty {
                let batch = FirebaseConstants.database.batch()
                for message in snapshot.documents {
                    batch.deleteDocument(message.reference)
                }
                batch.commit { error in
                    if let error = error { completion(error) }
                }
                // Deletion succeeded.
                completion(nil)
            } else if let error = error {
                completion(error)
            }
        }
    }
}
