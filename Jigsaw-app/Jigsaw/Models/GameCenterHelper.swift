//
//  GameCenterHelper.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import GameKit

class GameCenterHelper: NSObject, GKLocalPlayerListener {
    static let shared = GameCenterHelper()
    
    var viewController: UIViewController?
    
    static var isAuthenticated: Bool {
        return GKLocalPlayer.local.isAuthenticated
    }
    
    private let averageScoreLeaderboardID = "edu.duke.mobilecenter.JigsawBeta.averageScore"
    private let economyFinishedAchievementID = "edu.duke.mobilecenter.JigsawBeta.economyFinished"
    
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
}

extension GameCenterHelper: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true)
    }
}

private extension Notification.Name {
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}
