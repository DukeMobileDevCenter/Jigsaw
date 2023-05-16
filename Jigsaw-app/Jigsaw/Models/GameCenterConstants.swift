//
//  GameCenterConstants.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

enum GameCenterConstants {
    static let averageScoreLeaderboardID = Strings.GameCenterConstants.GameCenterConstants.averageScoreLeaderboardID
    static let gamesPlayedLeaderboardID = Strings.GameCenterConstants.GameCenterConstants.gamesPlayedLeaderboardID
    
    static func getFinishedAchievementID(for category: GameCategory) -> String? {
        switch category {
        case .economy:
            return Strings.GameCenterConstants.GameCenterConstants.GetFinishedAchievementID.Category.economy
        case .justice, .immigration, .environment, .health, .international, .charterSchools, .minimumWage:
            // FIXME: for beta, temporary disable other categories
            // as no available/designed achievements yet.
            return nil
        case .random, .demo:
            return nil
        }
    }
}
