//
//  GameCategory.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import UIKit

enum GameCategory: String, CaseIterable, Codable {
    case immigration
    case economy
    case justice
    case environment
    case health
    case international
    case random
    case charterSchools
    case minimumWage
    case demo
    
    var iconImage: UIImage {
        let iconImage: UIImage
        switch self {
        case .immigration:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.immigration)!
        case .economy:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.economy)!
        case .justice:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.justice)!
        case .environment:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.environment)!
        case .health:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.health)!
        case .international:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.international)!
        case .random:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.random)!
        case .demo:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.demo)!
        case .minimumWage:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.minimumWage)!
        case .charterSchools:
            iconImage = UIImage(systemName: Strings.GameCategory.IconImage.charterSchools)!
        }
        return iconImage
    }
    
    var backgroundImage: UIImage {
        return UIImage(named: "bg-\(self.rawValue)")!
    }
    
    var label: String {
        switch self {
        case .immigration:
            return Strings.GameCategory.Label.immigration
        case .economy:
            return Strings.GameCategory.Label.charterSchools
        case .justice:
            return Strings.GameCategory.Label.justice
        case .environment:
            return Strings.GameCategory.Label.environment
        case .health:
            return Strings.GameCategory.Label.health
        case .international:
            return Strings.GameCategory.Label.international
        case .random:
            return Strings.GameCategory.Label.random
        case .demo:
            return Strings.GameCategory.Label.demo
        case .charterSchools:
            return Strings.GameCategory.Label.charterSchools
        case .minimumWage:
            return Strings.GameCategory.Label.minimumWage
        }
    }
    
    var detailText: String {
        switch self {
        case .immigration:
            return Strings.GameCategory.DetailText.immigration
        case .economy:
            return Strings.GameCategory.DetailText.economy
        case .justice:
            return Strings.GameCategory.DetailText.justice
        case .environment:
            return Strings.GameCategory.DetailText.environment
        case .health:
            return Strings.GameCategory.DetailText.health
        case .international:
            return Strings.GameCategory.DetailText.international
        case .random:
            return Strings.GameCategory.DetailText.random
        case .demo:
            return Strings.GameCategory.DetailText.demo
        case .minimumWage:
            return Strings.GameCategory.DetailText.minimumWage
        case .charterSchools:
            return Strings.GameCategory.DetailText.charterSchools
        }
    }
}

class GameCategoryClass: NSObject, UICollectionViewDataSource {
    // Singleton of the class.
    static let shared = GameCategoryClass()
    
    // FIXME: for beta, don't include the random option.
    /// A wrapper to all of the enum cases.
    // let allCases = GameCategory.allCases.dropLast()
    var foundCategories: [GameCategory] {
        var categories = [GameCategory]()
        
        GameStore.shared.allGames.forEach { game in
            if !categories.contains(game.category) {
                categories.append(game.category)
            }
        }
        
        return categories
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("foundCategories.count \(foundCategories.count)")
        return foundCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        let category = foundCategories[indexPath.item]
        cell.nameLabel.text = category.label
        cell.iconImageView.setImage(category.iconImage)
        cell.backgroundImageView.setImage(category.backgroundImage)
        return cell
    }
}
