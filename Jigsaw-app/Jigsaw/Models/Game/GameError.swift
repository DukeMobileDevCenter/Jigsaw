//
//  GameError.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum GameError: LocalizedError, CustomStringConvertible {
    case currentPlayerDropped
    case otherPlayerDropped
    case maxAttemptReached
    case currentPlayerFailed(Int)
    case otherPlayerFailed
    case unknown
    
    var description: String {
        switch self {
        case .currentPlayerDropped:
            return Strings.GameError.GameError.Description.currentPlayerDropped
        case .otherPlayerDropped:
            return Strings.GameError.GameError.Description.otherPlayerDropped
        case .maxAttemptReached:
            // Also means the current player dropped.
            return Strings.GameError.GameError.Description.maxAttemptReached
        case .currentPlayerFailed(let wrongCount):
            return "🤨 You didn't pass the room with \(wrongCount) wrong answers.\nDiscuss and try again!"
        case .otherPlayerFailed:
            return Strings.GameError.GameError.Description.otherPlayerFailed
        case .unknown:
            return Strings.GameError.GameError.Description.unknown
        }
    }
}
