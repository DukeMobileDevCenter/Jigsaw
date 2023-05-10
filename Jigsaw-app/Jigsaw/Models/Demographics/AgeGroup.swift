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
            return Strings.AgeGroup.AgeGroup.Label.group15minus
        case .group1520:
            return Strings.AgeGroup.AgeGroup.Label.group1520
        case .group2130:
            return Strings.AgeGroup.AgeGroup.Label.group2130
        case .group3140:
            return Strings.AgeGroup.AgeGroup.Label.group3140
        case .group4150:
            return Strings.AgeGroup.AgeGroup.Label.group4150
        case .group5160:
            return Strings.AgeGroup.AgeGroup.Label.group5160
        case .group61plus:
            return Strings.AgeGroup.AgeGroup.Label.group61plus
        case .unknown:
            return Strings.AgeGroup.AgeGroup.Label.unknown
        }
    }
}
