//
//  EducationLevel.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/18/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum EducationLevel: String, CaseIterable, Codable, CaseReverseInit {
    case highSchool
    case college
    case graduate
    case postGraduate
    case unknown
    
    static let mappingDict: [String: Self] = Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.label, $0) })
    
    init?(label: String) {
        guard let newCase = Self.mappingDict[label] else { return nil }
        self = newCase
    }
    
    var label: String {
        switch self {
        case .highSchool:
            return "High school or less"
        case .college:
            return "Some college"
        case .graduate:
            return "College graduate"
        case .postGraduate:
            return "Post graduates"
        case .unknown:
            return "Prefer not to answer"
        }
    }
}
