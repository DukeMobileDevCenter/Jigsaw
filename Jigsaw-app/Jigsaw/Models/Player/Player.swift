//
//  Player.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

struct Player: Codable {
    let userID: String
    var displayName: String
    var jigsawValue: Double
    let joinDate: Date
    var email: String?
    var demographics: [String: String?]
}
