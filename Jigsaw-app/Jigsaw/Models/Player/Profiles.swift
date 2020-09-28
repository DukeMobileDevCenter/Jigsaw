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
        return "userID: \(Profiles.userID ?? "nil"), displayName: \(Profiles.displayName ?? "nil"), jigsawValue: \(Profiles.jigsawValue)"
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
    
    private enum SettingKeys: String, CaseIterable {
        case userID
        case displayName
        case jigsawValue
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
            let defaults = UserDefaults.standard
            let key = SettingKeys.jigsawValue.rawValue
            defaults.set(newValue, forKey: key)
        }
    }
}
