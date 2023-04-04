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
            return Strings.EducationLevel.EducationLevel.Label.highSchool
        case .college:
            return Strings.EducationLevel.EducationLevel.Label.college
        case .graduate:
            return Strings.EducationLevel.EducationLevel.Label.graduate
        case .postGraduate:
            return Strings.EducationLevel.EducationLevel.Label.postGraduate
        case .unknown:
            return Strings.EducationLevel.EducationLevel.Label.unknown
        }
    }
}
