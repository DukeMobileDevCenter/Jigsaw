//
//  GameStore.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

private class GameCollections {
    var immigrationGames = [Game]()
    var economyGames = [Game]()
    var lawGames = [Game]()
    var environmentGames = [Game]()
    var healthGames = [Game]()
    
    func sortAll() {
        let levelAscending: (Game, Game) -> Bool = { $0.level < $1.level }
        immigrationGames.sort(by: levelAscending)
        economyGames.sort(by: levelAscending)
        lawGames.sort(by: levelAscending)
        environmentGames.sort(by: levelAscending)
        healthGames.sort(by: levelAscending)
    }
    
    func removeAll() {
        immigrationGames.removeAll()
        economyGames.removeAll()
        lawGames.removeAll()
        environmentGames.removeAll()
        healthGames.removeAll()
    }
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
    
    // swiftlint:disable cyclomatic_complexity
    func loadGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        var games = [Game]()
        // Clear all existing games.
        collections.removeAll()
        FirebaseConstants.shared.games.getDocuments { [weak self] querySnapshot, error in
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
                self.collections.sortAll()
                self.allGames = games
                completion(.success(games))
            } else if let error = error {
                completion(.failure(error))
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity
}

extension GameStore: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getGames(for: selectedCategory).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        
        let game = getGames(for: selectedCategory)[indexPath.item]
        // Enable the level 1 rooms as well as other unlocked games.
        let isEnabled = game.level == 1 || Profiles.playedGameIDs.contains(game.previousLevelGameID)
        // Set subtitle.
        cell.nameLabel.text = isEnabled ? "\(game.gameName) room \(game.level)" : "???"
        // Set lock icon.
        cell.iconImageView.image = isEnabled ? UIImage(systemName: "lock.open")! : UIImage(systemName: "lock")!
        
        if isEnabled {
            // Lazy load background image.
            cell.backgroundImageView.pin_updateWithProgress = true
            cell.backgroundImageView.pin_setImage(from: game.backgroundImageURL)
        }
        // Disable higher levels that a player hasn't reached.
        cell.isUserInteractionEnabled = isEnabled
        
        return cell
    }
}
