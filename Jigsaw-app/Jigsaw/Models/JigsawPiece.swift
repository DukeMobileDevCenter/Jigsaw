//
//  JigsawPiece.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum JigsawPiece: String, CaseIterable {
    case green, orange, purple, yellow, unknown
    
    /// A human readable string of the jigsaw piece name.
    var label: String {
        switch self {
        case .green:
            return "Green piece"
        case .orange:
            return "Orange piece"
        case .purple:
            return "Purple piece"
        case .yellow:
            return "Yellow piece"
        case .unknown:
            return "Unknown piece"
        }
    }
    
    /// The filename of each jigsaw piece image.
    var bundleName: String {
        switch self {
        case .green:
            return "jigsaw-green"
        case .orange:
            return "jigsaw-orange"
        case .purple:
            return "jigsaw-purple"
        case .yellow:
            return "jigsaw-yellow"
        case .unknown:
            return "jigsaw-unknown"
        }
    }
}
