//
//  JigsawPiece.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/13/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum JigsawPiece: String, CaseIterable, CaseReverseInit {
    case green, orange, purple, yellow, unknown
    
    static let mappingDict: [String: Self] = Dictionary(uniqueKeysWithValues: Self.allCases.map { ($0.label, $0) })
    
    init?(label: String) {
        guard let newCase = Self.mappingDict[label] else { return nil }
        self = newCase
    }
    
    init(index: Int) {
        switch index {
        case 0:
            self = .green
        case 1:
            self = .orange
        case 2:
            self = .purple
        case 3:
            self = .yellow
        default:
            self = .unknown
        }
    }
    
    /// A human readable string of the jigsaw piece name.
    var label: String {
        switch self {
        case .green:
            return Strings.JigsawPiece.JigsawPiece.Label.green
        case .orange:
            return Strings.JigsawPiece.JigsawPiece.Label.orange
        case .purple:
            return Strings.JigsawPiece.JigsawPiece.Label.purple
        case .yellow:
            return Strings.JigsawPiece.JigsawPiece.Label.yellow
        case .unknown:
            return Strings.JigsawPiece.JigsawPiece.Label.unknown
        }
    }
    
    /// The filename of each jigsaw piece image.
    var bundleName: String {
        switch self {
        case .green:
            return Strings.JigsawPiece.JigsawPiece.BundleName.green
        case .orange:
            return Strings.JigsawPiece.JigsawPiece.BundleName.orange
        case .purple:
            return Strings.JigsawPiece.JigsawPiece.BundleName.purple
        case .yellow:
            return Strings.JigsawPiece.JigsawPiece.BundleName.yellow
        case .unknown:
            return Strings.JigsawPiece.JigsawPiece.BundleName.unknown
        }
    }
}
