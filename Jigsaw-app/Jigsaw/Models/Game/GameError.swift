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
    case currentPlayerFailed
    
    var description: String {
        switch self {
        case .otherPlayerDropped:
            return "😢 One of your peers did not pass the game."
        case .maxAttemptReached:
            return "😞 Max attempt reached. Game fails!"
        case .currentPlayerFailed:
            return "🤨 Uh-oh. You didn't pass the game. Discuss and try again!"
        }
    }
}
