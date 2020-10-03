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
    
    override init() {
        super.init()
        
        GKLocalPlayer.local.authenticateHandler = { gcAuthVC, error in
            NotificationCenter.default.post(name: .authenticationChanged, object: GKLocalPlayer.local.isAuthenticated)
            
            if GKLocalPlayer.local.isAuthenticated {
                GKLocalPlayer.local.register(self)
            } else if let vc = gcAuthVC {
                self.viewController?.present(vc, animated: true)
            } else if let error = error {
                print("Error authentication to GameCenter: \(error.localizedDescription)")
            }
        }
    }
}

extension Notification.Name {
    static let authenticationChanged = Notification.Name(rawValue: "authenticationChanged")
}

