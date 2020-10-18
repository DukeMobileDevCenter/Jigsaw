//
//  Profiles.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

class Profiles: CustomStringConvertible {
    /// A custom description that prints out basic info.
    var description: String {
        return "userID: \(Profiles.userID ?? "nil"), displayName: \(Profiles.displayName ?? "nil"), jigsawValue: \(Profiles.jigsawValue).\nLast time game loaded at \(Profiles.lastLoadGameDate.description)."
    }
    
    /// A class function to clear away all info.
    static func resetProfiles() {
        userID = nil
        displayName = nil
        jigsawValue = 0.5
        playedGameIDs.removeAll()
        currentPlayer = nil
    }
    
    /// A copy of the current `Player` struct.
    static var currentPlayer: Player! = nil
    /// A set of strings for IDs of played game.
    static var playedGameIDs = Set<String>()
    /// The game group's ID where the current player is in. If the player is not in a game, then it is nil.
    static var currentGroupID: String?
    
    private enum SettingKeys: String, CaseIterable {
        // User info.
        case userID
        case displayName
        case jigsawValue
        // Onboarding state.
        case onboardingCompleted
        // Data timestamp.
        case lastLoadGameDate
    }
    
    static var userID: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingKeys.userID.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKeys.userID.rawValue
            
            if let userID = newValue {
                defaults.set(userID, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var displayName: String! {
        get {
            return UserDefaults.standard.string(forKey: SettingKeys.displayName.rawValue)
        }
        set {
            let defaults = UserDefaults.standard
            let key = SettingKeys.displayName.rawValue
            
            if let name = newValue {
                defaults.set(name, forKey: key)
            } else {
                defaults.removeObject(forKey: key)
            }
        }
    }
    
    static var jigsawValue: Double {
        get {
            return UserDefaults.standard.double(forKey: SettingKeys.jigsawValue.rawValue)
        }
        set(newValue) {
            let key = SettingKeys.jigsawValue.rawValue
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    /// A key to indicate if current user has done onboarding.
    static var onboardingCompleted: Bool {
        get {
            return UserDefaults.standard.bool(forKey: SettingKeys.onboardingCompleted.rawValue)
        }
        set(newValue) {
            let key = SettingKeys.onboardingCompleted.rawValue
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
    
    static var lastLoadGameDate: Date! {
        get {
            return Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: SettingKeys.lastLoadGameDate.rawValue))
        }
        set(newValue) {
            let key = SettingKeys.lastLoadGameDate.rawValue
            UserDefaults.standard.set(newValue.timeIntervalSince1970, forKey: key)
        }
    }
}
