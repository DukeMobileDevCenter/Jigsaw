//
//  PlayersQueue.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/16/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

enum PlayersQueue: String {
    case twoPlayersQueue
    case fourPlayersQueue
    
    var playerCount: Int {
        switch self {
        case .twoPlayersQueue:
            return 2
        case .fourPlayersQueue:
            return 4
        }
    }
}
