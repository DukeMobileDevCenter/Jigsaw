//
//  Ethnicity.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/18/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum Ethnicity: String, CaseIterable, Codable, CaseReverseInit {
    case white
    case black
    case hispanic
    case asian
    case others
    case unknown
    
    static let mappingDict: [String: Self] = Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.label, $0) })
    
    init?(label: String) {
        guard let newCase = Self.mappingDict[label] else { return nil }
        self = newCase
    }
    
    var label: String {
        switch self {
        case .white:
            return "White"
        case .black:
            return "Black"
        case .hispanic:
            return "Hispanic or Latino"
        case .asian:
            return "Asian"
        case .others:
            return "Others"
        case .unknown:
            return "Prefer not to answer"
        }
    }
}
