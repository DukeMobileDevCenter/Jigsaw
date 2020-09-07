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
    case education
    case housing
    case medicare
    case taxation
    
    var iconImage: UIImage {
        let iconImage: UIImage
        switch self {
        case .immigration:
            iconImage = UIImage(systemName: "hand.raised.slash")!
        case .education:
            iconImage = UIImage(systemName: "book")!
        case .housing:
            iconImage = UIImage(systemName: "house")!
        case .medicare:
            iconImage = UIImage(systemName: "staroflife")!
        case .taxation:
            iconImage = UIImage(systemName: "dollarsign.circle")!
        }
        return iconImage
    }
}
