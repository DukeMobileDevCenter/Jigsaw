//
//  GameError.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum GameError: LocalizedError, CustomStringConvertible {
    case otherPlayerDropped
    case maxAttemptReached
    case currentPlayerFailed(Int)
    
    var description: String {
        switch self {
        case .otherPlayerDropped:
            return "😢 One of your peers didn't pass the game."
        case .maxAttemptReached:
            return "😞 Max attempts reached."
        case .currentPlayerFailed(let wrongCount):
            return "🤨 Uh-oh. You didn't pass the game with \(wrongCount) wrong answers.\nDiscuss and try again!"
        }
    }
}
