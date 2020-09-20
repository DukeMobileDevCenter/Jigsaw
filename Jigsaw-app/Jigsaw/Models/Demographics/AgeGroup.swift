//
//  AgeGroup.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum AgeGroup: String, CaseIterable, Codable, CaseReverseInit {
    case group15minus
    case group1520
    case group2130
    case group3140
    case group4150
    case group5160
    case group61plus
    case unknown
    
    static let mappingDict: [String: Self] = Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.label, $0) })
    
    init?(label: String) {
        guard let newCase = AgeGroup.mappingDict[label] else { return nil }
        self = newCase
    }
    
    var label: String {
        switch self {
        case .group15minus:
            return "15-"
        case .group1520:
            return "15-20"
        case .group2130:
            return "21-30"
        case .group3140:
            return "31-40"
        case .group4150:
            return "41-50"
        case .group5160:
            return "51-60"
        case .group61plus:
            return "61+"
        case .unknown:
            return "Prefer not to answer"
        }
    }
}
