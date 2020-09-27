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
    /// Singleton of the `GameStore` class.
    static let shared = GameStore()
    /// A reference singleton to the `GameCollections` class.
    private let collections = GameCollections()
    /// An array that holds all games fetched from Firebase.
    var allGames = [Game]()
    /// The category which the GameStore should provide datasource.
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
    
    /// Load all games from Firebase and save to respective categories.
    ///
    /// - Parameter completion: A closure that passes back an array of Games/rooms or an error.
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
    
    /// Find next level room for current room/game.
    ///
    /// - Parameter currentGame: The room/game the player is currently in.
    /// - Returns: The next level room if exists.
    func nextGame(for currentGame: Game) -> Game? {
        return allGames.first { $0.gameID == currentGame.nextLevelGameID }
    }
}

extension GameStore: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        getGames(for: selectedCategory).count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        // Find game.
        let game = getGames(for: selectedCategory)[indexPath.item]
        // Set subtitle.
        cell.nameLabel.text = game.isEnabled ? "\(game.gameName) room \(game.level)" : "???"
        // Set lock icon.
        cell.iconImageView.image = game.isEnabled ? UIImage(systemName: "lock.open")! : UIImage(systemName: "lock")!
        // Set background image.
        if game.isEnabled {
            // Lazy load background image.
            cell.backgroundImageView.pin_updateWithProgress = true
            cell.backgroundImageView.pin_setImage(from: game.backgroundImageURL)
        }
        // Disable higher levels that a player hasn't reached.
        cell.isUserInteractionEnabled = game.isEnabled
        
        return cell
    }
}
