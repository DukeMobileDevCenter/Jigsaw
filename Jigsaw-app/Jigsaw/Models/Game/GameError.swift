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
            return "😢 You didn't pass the game."
        case .otherPlayerDropped:
            return "😢 Your peers didn't pass the game."
        case .maxAttemptReached:
            // Also means the current player dropped.
            return "😞 Max attempts reached."
        case .currentPlayerFailed(let wrongCount):
            return "🤨 Uh-oh. You didn't pass the room with \(wrongCount) wrong answers.\nDiscuss and try again!"
        case .otherPlayerFailed:
            return "🤨 Uh-oh. Your peers didn't pass the room.\nHelp them and try again!"
        case .unknown:
            return "🤐 Unknown error. Developers are trembling."
        }
    }
}
