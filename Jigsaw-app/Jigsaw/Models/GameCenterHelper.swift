//
//  GameCenterHelper.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import os
import GameKit

class GameCenterHelper: NSObject, GKLocalPlayerListener {
    /// A singleton of the helper class.
    static let shared = GameCenterHelper()
    /// The view controller to present GameCenterViewController.
    var viewController: UIViewController?
    
    // Not used yet.
    private var achievements = [GKAchievement]()
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.localPlayer().isAuthenticated
    }
    
    /// The GameCenterViewController that displays player stats.
    /// Create it everytime so the controller have correct appearances.
    private var gameCenterViewController: GKGameCenterViewController {
        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self
        return controller
    }
    
    override init() {
        super.init()
        
        GKLocalPlayer.localPlayer().authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.localPlayer().isAuthenticated)
            
            if GKLocalPlayer.localPlayer().isAuthenticated {
                GKLocalPlayer.localPlayer().register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else if let error = error {
                self.viewController?.presentAlert(error: error)
            }
        }
    }
    
    // Not used yet.
    private func loadAchievements() {
        GKAchievement.loadAchievements { achievements, error in
            if let achievements = achievements {
                self.achievements = achievements
            } else if let error = error {
                os_log(.error, "Error: %@", error.localizedDescription)
            }
        }
    }
    
    func presentLeaderBoard() {
        gameCenterViewController.viewState = .leaderboards
        viewController?.present(gameCenterViewController, animated: true)
    }
    
    func presentAchievements() {
        gameCenterViewController.viewState = .achievements
        viewController?.present(gameCenterViewController, animated: true)
    }
    
    func submitAverageScore(_ score: Double) {
        let averageScore = GKScore(leaderboardIdentifier: GameCenterConstants.averageScoreLeaderboardID)
        averageScore.value = Int64(score)
        GKScore.report([averageScore]) { error in
            if let error = error {
                os_log(.error, "Error: %@", error.localizedDescription)
            } else {
                os_log(.info, "✅ Average score reported.")
            }
        }
    }
    
    func submitGamesPlayed(_ count: Int) {
        let gamesPlayed = GKScore(leaderboardIdentifier: GameCenterConstants.gamesPlayedLeaderboardID)
        gamesPlayed.value = Int64(count)
        GKScore.report([gamesPlayed]) { error in
            if let error = error {
                os_log(.error, "Error: %@", error.localizedDescription)
            } else {
                os_log(.info, "✅ Games played reported.")
            }
        }
    }
    
    /// Submit the progress for category/topic finished achievements.
    ///
    /// - Note: Please refer to percent complete [doc](https://developer.apple.com/documentation/gamekit/gkachievement/1520939-percentcomplete).
    ///
    /// - Parameters:
    ///   - category: The category of the achievement.
    ///   - percentComplete: The percentage of the achievement, i.e. (rooms played)/(total rooms count).
    func submitFinishedAchievement(for category: GameCategory, progress percentComplete: Double) {
        guard let achievementID = GameCenterConstants.getFinishedAchievementID(for: category) else { return }
        let achievement = GKAchievement(identifier: achievementID)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        GKAchievement.report([achievement]) { error in
            if let error = error {
                os_log(.error, "Error: %@", error.localizedDescription)
            } else {
                os_log(.info, "✅ Achievement reported for %@", category.label)
            }
        }
    }
}

extension GameCenterHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

extension Notification.Name {
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
