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
    
    var iconImage: UIImage {
        let iconImage: UIImage
        switch self {
        case .immigration:
            iconImage = UIImage(systemName: "hand.raised.slash")!
        case .economy:
            iconImage = UIImage(systemName: "dollarsign.circle")!
        case .justice:
            iconImage = UIImage(systemName: "shield.lefthalf.fill")!
        case .environment:
            iconImage = UIImage(systemName: "cloud.sun")!
        case .health:
            iconImage = UIImage(systemName: "staroflife")!
        case .international:
            iconImage = UIImage(systemName: "globe")!
        case .random:
            iconImage = UIImage(systemName: "questionmark")!
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
            return "Economy"
        case .justice:
            return "Justice"
        case .environment:
            return "Environment"
        case .health:
            return "Health"
        case .international:
            return "International"
        case .random:
            return "Random"
        }
    }
    
    var detailText: String {
        switch self {
        case .immigration:
            return "Immigration is the international movement of people to a destination country of which they are not natives or where they do not possess citizenship in order to settle as permanent residents or naturalized citizens."
        case .economy:
            return "Economy is defined as a social domain that emphasize the practices, discourses, and material expressions associated with the production, use, and management of resources."
        case .justice:
            return "Law commonly refers to a system of rules created and enforced through social or governmental institutions to regulate behavior."
        case .environment:
            return "The natural environment encompasses all living and non-living things occurring naturally, meaning in this case not artificial."
        case .health:
            return "Health is a state of physical, mental and social well-being in which disease and infirmity are absent."
        case .international:
            return "International is an adjective (also used as a noun) meaning \"between nations\"."
        case .random:
            return "Lead me to a random topic!"
        }
    }
}

class GameCategoryClass: NSObject, UICollectionViewDataSource {
    // Singleton of the class.
    static let shared = GameCategoryClass()
    
    // FIXME: for beta testing, don't include the random option.
    /// A wrapper to all of the enum cases.
    let allCases = GameCategory.allCases.dropLast()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCollectionCell", for: indexPath) as! GameCollectionCell
        let category = allCases[indexPath.item]
        cell.nameLabel.text = category.label
        cell.iconImageView.setImage(category.iconImage)
        cell.backgroundImageView.setImage(category.backgroundImage)
        return cell
    }
}
