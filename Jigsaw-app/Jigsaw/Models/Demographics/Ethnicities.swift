//
//  Ethnicities.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/18/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum Ethnicities: String, CaseIterable, Codable {
    case white = "White"
    case black = "Black"
    case hispanic = "Hispanic or Latino"
    case asian = "Asian"
    case others = "Others"
    case unknown = "Prefer not to answer"
}
