//
//  Gender.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/4/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum Gender: String, CaseIterable, Codable, CaseReverseInit {
    case male
    case female
    case other
    case unknown
    
    static let mappingDict: [String: Self] = Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.label, $0) })
    
    init?(label: String) {
        guard let newCase = Self.mappingDict[label] else { return nil }
        self = newCase
    }
    
    var label: String {
        switch self {
        case .male:
            return "Male"
        case .female:
            return "Female"
        case .other:
            return "Other"
        case .unknown:
            return "Prefer not to answer"
        }
    }
}
