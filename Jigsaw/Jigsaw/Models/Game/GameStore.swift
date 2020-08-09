//
//  GameStore.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

class GameStore {
    // Singleton of the class.
    static let shared = GameStore()
    var allGames = [Game]()
    
    private func fetchGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        let db = Firestore.firestore()
        var games = [Game]()
        db.collection("Games").getDocuments { querySnapshot, error in
            if let snapshot = querySnapshot {
                for document in snapshot.documents {
                    do {
                        if let game = try document.data(as: Game.self) {
                            games.append(game)
                        }
                    } catch {
                        completion(.failure(error))
                        return
                    }
                }
                completion(.success(games))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}
