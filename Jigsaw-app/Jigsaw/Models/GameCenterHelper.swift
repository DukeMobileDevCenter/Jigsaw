//
//  GameCenterHelper.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import GameKit

class GameCenterHelper: NSObject, GKLocalPlayerListener {
    /// A singleton of the helper class.
    static let shared = GameCenterHelper()
    /// The view controller to present GameCenterViewController.
    var viewController: UIViewController?
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    // MARK: Constants
    
    private let averageScoreLeaderboardID = "edu.duke.mobilecenter.JigsawBeta.averageScore"
    private let economyFinishedAchievementID = "edu.duke.mobilecenter.JigsawBeta.economyFinished"
    
    /// The GameCenterViewController that displays player stats.
    private lazy var gameCenterViewController: GKGameCenterViewController = {
        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self
        return controller
    }()
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else if let error = error {
                self.viewController?.presentAlert(error: error)
            }
        }
    }
    
    func presentLeaderBoard() {
        gameCenterViewController.viewState = .leaderboards
        gameCenterViewController.leaderboardIdentifier = averageScoreLeaderboardID
        viewController?.present(gameCenterViewController, animated: true)
    }
    
    func presentAchievements() {
        gameCenterViewController.viewState = .achievements
        viewController?.present(gameCenterViewController, animated: true)
    }
    
    func submitAverageScore(_ score: Double) {
        let averageScore = GKScore(leaderboardIdentifier: averageScoreLeaderboardID)
        averageScore.value = Int64(score)
        GKScore.report([averageScore]) { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("✅ Average score reported.")
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
