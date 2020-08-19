//
//  Genders.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/4/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum Genders: String, CaseIterable, Codable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
    case unknown = "Prefer not to answer"
}
