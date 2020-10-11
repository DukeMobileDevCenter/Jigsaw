//
//  GameStore.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Yams

private class GameCollections {
    var immigrationGames = [Game]()
    var economyGames = [Game]()
    var justiceGames = [Game]()
    var environmentGames = [Game]()
    var healthGames = [Game]()
    var internationalGames = [Game]()
    
    func sortAll() {
        let levelAscending: (Game, Game) -> Bool = { $0.level < $1.level }
        immigrationGames.sort(by: levelAscending)
        economyGames.sort(by: levelAscending)
        justiceGames.sort(by: levelAscending)
        environmentGames.sort(by: levelAscending)
        healthGames.sort(by: levelAscending)
        internationalGames.sort(by: levelAscending)
    }
    
    func removeAll() {
        immigrationGames.removeAll()
        economyGames.removeAll()
        justiceGames.removeAll()
        environmentGames.removeAll()
        healthGames.removeAll()
        internationalGames.removeAll()
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
        case .justice:
            return collections.justiceGames
        case .environment:
            return collections.environmentGames
        case .health:
            return collections.healthGames
        case .international:
            return collections.internationalGames
        case .random:
            return []
        }
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    
    /// Load all games from Firebase and save to respective categories.
    ///
    /// - Parameter completion: A closure that passes back an array of Games/rooms or an error.
    func loadGames(completion: @escaping (Result<[Game], Error>) -> Void) {
        // Clear all existing games.
        collections.removeAll()
        FirebaseConstants.shared.gamesStorage.listAll { [weak self] storageListResult, error in
            guard let self = self else { return }
            if let error = error {
                completion(.failure(error))
                return
            }
            // Create copies to avoid async race condition.
            var games = [Game]()
            
            var immigrationGames = [Game]()
            var economyGames = [Game]()
            var justiceGames = [Game]()
            var environmentGames = [Game]()
            var healthGames = [Game]()
            var internationalGames = [Game]()
            
            let downloadGroup = DispatchGroup()
            
            for item in storageListResult.items {
                downloadGroup.enter()
                // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
                item.getData(maxSize: 1 * 1024 * 1024) { data, error in
                    // Leave after the call finishes.
                    defer { downloadGroup.leave() }
                    
                    if let error = error {
                        completion(.failure(error))
                        return
                    }
                    if let data = data,
                       let content = String(data: data, encoding: .utf8),
                       let dataDict = try? Yams.load(yaml: content) as? [String: Any] {
                        if let game = Game(data: dataDict) {
                            let category = game.category
                            switch category {
                            case .immigration:
                                immigrationGames.append(game)
                            case .economy:
                                economyGames.append(game)
                            case .justice:
                                justiceGames.append(game)
                            case .environment:
                                environmentGames.append(game)
                            case .health:
                                healthGames.append(game)
                            case .international:
                                internationalGames.append(game)
                            case .random:
                                break
                            }
                            games.append(game)
                        }
                    }
                }
            }
            // Only callback success when all downloads are successful.
            downloadGroup.notify(queue: .main) { [weak self] in
                guard let self = self else { return }
                // Sorted by latest added version number.
                games.sort { game1, game2 in game1.level < game2.level }
                // Assign the games in whole to avoid race condition.
                self.allGames = games
                
                self.collections.immigrationGames = immigrationGames
                self.collections.economyGames = economyGames
                self.collections.justiceGames = justiceGames
                self.collections.environmentGames = environmentGames
                self.collections.healthGames = healthGames
                self.collections.internationalGames = internationalGames
                self.collections.sortAll()
                
                completion(.success(games))
            }
        }
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
    
    /// Find next level room for current room/game.
    ///
    /// - Parameter currentGame: The room/game the player is currently in.
    /// - Returns: The next level room if exists.
    func nextGame(for currentGame: Game) -> Game? {
        return allGames.first { $0.gameID == currentGame.nextLevelGameID }
    }
    
    /// Get the played games ratio, i.e. (rooms played)/(total rooms count), for a category.
    ///
    /// - Parameter category: The category of rooms.
    /// - Returns: The percentage between 0.0 and 100.0.
    func percentComplete(for category: GameCategory) -> Double {
        let games = getGames(for: category)
        if games.isEmpty { return 0 }
        return Double(games.filter { $0.isPlayed }.count) / Double(games.count) * 100
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
        
        if game.isEnabled {
            cell.nameLabel.text = "\(game.gameName) room \(game.level)"
            // Do not show the icon when the game is enabled.
            cell.iconImageView.isHidden = true
            cell.iconBackgroundView.isHidden = true
            // Lazy load background image.
            cell.backgroundImageView.pin_updateWithProgress = true
            cell.backgroundImageView.pin_setImage(from: game.backgroundImageURL)
        } else {
            // Set subtitle.
            cell.nameLabel.text = "???"
            // Set lock icon.
            cell.iconImageView.isHidden = false
            cell.iconImageView.image = UIImage(systemName: "lock")!
            cell.iconBackgroundView.isHidden = false
            // Clear the image for reusing the cell.
            cell.backgroundImageView.image = nil
        }
        // Disable higher levels that a player hasn't reached.
        cell.isUserInteractionEnabled = game.isEnabled
        
        return cell
    }
}
