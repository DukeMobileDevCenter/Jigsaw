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
            iconImage = UIImage(systemName: "shield.lefthalf.fill")!
        case .economy:
            iconImage = UIImage(systemName: "books.vertical.fill")!
        case .justice:
            iconImage = UIImage(systemName: "banknote.fill")!
        case .environment:
            iconImage = UIImage(systemName: "rectangle.badge.checkmark")!
        case .health:
            iconImage = UIImage(systemName: "dollarsign.circle")!
        case .international:
            iconImage = UIImage(systemName: "equal.circle.fill")!
        case .random:
            iconImage = UIImage(systemName: "questionmark")!
        case .demo:
            iconImage = UIImage(systemName: "questionmark")!
        case .minimumWage:
            iconImage = UIImage(systemName: "dollarsign.circle")!
        case .charterSchools:
            iconImage = UIImage(systemName: "book")!
        }
        return iconImage
    }
    
    var backgroundImage: UIImage {
        return UIImage(named: "bg-\(self.rawValue)")!
    }
    
    var label: String {
        switch self {
        case .immigration:
            return "Immigration"
        case .economy:
            return "Charter Schools"
        case .justice:
            return "Minimum Wage"
        case .environment:
            return "Electoral College"
        case .health:
            return "Economic Inequality"
        case .international:
            return "Affirmative Action"
        case .random:
            return "Random"
        case .demo:
            return "Demo"
        case .charterSchools:
            return "Charter Schools"
        case .minimumWage:
            return "Minimum Wage"
        }
    }
    
    var detailText: String {
        switch self {
        case .immigration:
            return "Immigration is the international movement of people to a destination country of which they are not natives or where they do not possess citizenship in order to settle as permanent residents or naturalized citizens."
        case .economy:
            return "Charter schools are publicly-funded, privately-operated schools."
        case .justice:
            return "Minimum wage is the legal minimum hourly wage a person may be paid for their labor."
        case .environment:
            return "Is it time to get rid of the Electoral College? The United States is unique in using an Electoral College to elect the President."
        case .health:
            return "Should the government reduce economic inequality by redistributing wealth?"
        case .international:
            return "Affirmative action refers to a policy of preferring minorities from underrepresented groups for college admission."
        case .random:
            return "Lead me to a random topic!"
        case .demo:
            return "Get ready to jump into adventure! Welcome to the exciting world of Jigsaw!"
        case .minimumWage:
            return "Minimum wage is the legal minimum hourly wage a person may be paid for their labor."
        case .charterSchools:
            return "Charter schools are publicly-funded, privately-operated schools."
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
