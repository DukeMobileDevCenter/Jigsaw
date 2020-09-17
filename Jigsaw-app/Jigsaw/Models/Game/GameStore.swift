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

private class GameCollections {
    var immigrationGames = [Game]()
    var economyGames = [Game]()
    var lawGames = [Game]()
    var environmentGames = [Game]()
    var healthGames = [Game]()
}

class GameStore: NSObject {
    // Singleton of the class.
    static let shared = GameStore()
    
    private let collections = GameCollections()
    
    var allGames = [Game]()
    
    var selectedCategory: GameCategory!
    
    func getGames(for category: GameCategory) -> [Game] {
        switch category {
        case .immigration:
            return collections.immigrationGames
        case .economy:
            return collections.economyGames
        case .law:
            return collections.lawGames
        case .environment:
            return collections.environmentGames
        case .health:
            return collections.healthGames
        case .random:
            return []
        }
    }
    
    func loadGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        let database = Firestore.firestore()
        var games = [Game]()
        database.collection("Games").getDocuments { [weak self] querySnapshot, error in
            guard let self = self else { return }
            if let snapshot = querySnapshot {
                for document in snapshot.documents {
                    if let game = Game(document: document) {
                        let category = game.category
                        switch category {
                        case .immigration:
                            self.collections.immigrationGames.append(game)
                        case .economy:
                            self.collections.economyGames.append(game)
                        case .law:
                            self.collections.lawGames.append(game)
                        case .environment:
                            self.collections.environmentGames.append(game)
                        case .health:
                            self.collections.healthGames.append(game)
                        case .random:
                            continue
                        }
                        games.append(game)
                    }
                }
                // Sorted by latest added version number.
                games.sort { game1, game2 in game1.level < game2.level }
                self.allGames = games
                completion(.success(games))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
}

extension GameStore: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getGames(for: selectedCategory).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        
        let game = getGames(for: selectedCategory)[indexPath.item]
        cell.nameLabel.text = game.gameName
        cell.iconImageView.image = game.category.iconImage
        
        // Lazy load background image.
        cell.backgroundImageView.pin_updateWithProgress = true
        cell.backgroundImageView.pin_setImage(from: game.backgroundImageURL)
        
        return cell
    }
}
