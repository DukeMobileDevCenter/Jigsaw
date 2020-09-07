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

class GameStore: NSObject {
    // Singleton of the class.
    static let shared = GameStore()
    
    var allGames = [Game]()
    
    func loadGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        let database = Firestore.firestore()
        var games = [Game]()
        database.collection("Games").getDocuments { [weak self] querySnapshot, error in
            if let snapshot = querySnapshot {
                for document in snapshot.documents {
                    if let game = Game(document: document) {
                        games.append(game)
                    }
                }
                // Sorted by latest added version number.
                games.sort { game1, game2 in game1.version > game2.version }
                self?.allGames = games
                completion(.success(games))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}

extension GameStore: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        
        let game = GameStore.shared.allGames[indexPath.item]
        cell.nameLabel.text = game.gameName
        cell.iconImageView.image = game.category.iconImage
        
        // Lazy load background image.
        cell.backgroundImageView.pin_updateWithProgress = true
        cell.backgroundImageView.pin_setImage(from: game.backgroundImageURL)
        
        return cell
    }
}
