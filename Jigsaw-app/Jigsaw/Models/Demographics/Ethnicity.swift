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
    case native
    case asian
    case other
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
            return "Black or African American"
        case .hispanic:
            return "Hispanic or Latino"
        case .native:
            return "American Indian or Alaska Native"
        case .asian:
            return "Asian"
        case .other:
            return "Other"
        case .unknown:
            return "Prefer not to answer"
        }
    }
}
