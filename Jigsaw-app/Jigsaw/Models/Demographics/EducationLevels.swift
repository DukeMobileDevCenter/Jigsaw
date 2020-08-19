//
//  EducationLevels.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/18/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum EducationLevels: String, CaseIterable, Codable {
    case highSchool = "High school or less"
    case college = "Some college"
    case graduate = "College graduate"
    case postGraduate = "Post graduates"
    case unknown = "Prefer not to answer"
}
