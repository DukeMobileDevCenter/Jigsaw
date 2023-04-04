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
            return Strings.Ethnicity.Ethnicity.Label.white
        case .black:
            return Strings.Ethnicity.Ethnicity.Label.black
        case .hispanic:
            return Strings.Ethnicity.Ethnicity.Label.hispanic
        case .native:
            return Strings.Ethnicity.Ethnicity.Label.native
        case .asian:
            return Strings.Ethnicity.Ethnicity.Label.asian
        case .other:
            return Strings.Ethnicity.Ethnicity.Label.other
        case .unknown:
            return Strings.Ethnicity.Ethnicity.Label.unknown
        }
    }
}
