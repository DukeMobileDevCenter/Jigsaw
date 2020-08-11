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
        let db = Firestore.firestore()
        var games = [Game]()
        db.collection("Games").getDocuments { [weak self] querySnapshot, error in
            if let snapshot = querySnapshot {
                for document in snapshot.documents {
                    do {
                        if let game = try document.data(as: Game.self) {
                            games.append(game)
                        }
                        self?.allGames = games
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

extension GameStore: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allGames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        
        let game = GameStore.shared.allGames[indexPath.item]
        cell.layer.masksToBounds = false
        cell.nameLabel.text = game.gameName
        
        cell.iconImageView.image = UIImage(systemName: "questionmark")!
        
        let bgImage = UIImage(named: "placeholder")
        cell.backgroundImageView.image = bgImage
        
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        
        return cell
    }
}
