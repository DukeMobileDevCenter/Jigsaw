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
    // Some dummy categories only for demo purposes
    case immigration
    case economy
    case law
    case environment
    case health
    
    var iconImage: UIImage {
        let iconImage: UIImage
        switch self {
        case .immigration:
            iconImage = UIImage(systemName: "hand.raised.slash")!
        case .economy:
            iconImage = UIImage(systemName: "dollarsign.circle")!
        case .law:
            iconImage = UIImage(systemName: "shield.lefthalf.fill")!
        case .environment:
            iconImage = UIImage(systemName: "cloud.sun")!
        case .health:
            iconImage = UIImage(systemName: "staroflife")!
        }
        return iconImage
    }
    
    var label: String {
        switch self {
        case .immigration:
            return "Immigration"
        case .economy:
            return "Economy"
        case .law:
            return "Law"
        case .environment:
            return "Environment"
        case .health:
            return "Health"
        }
    }
}
