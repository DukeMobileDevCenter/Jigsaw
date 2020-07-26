//
//  OnboardingStateManager.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

class OnboardingStateManager: NSObject {
    static let shared = OnboardingStateManager()
    let onboardingCompletedKey = "OnboardingCompletedKey"
    
    func setOnboardingCompletedState(state: Bool) {
        let defaults = UserDefaults.standard
        defaults.set(state, forKey: onboardingCompletedKey)
    }
    
    func getOnboardingCompletedState() -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: onboardingCompletedKey)
    }
}
