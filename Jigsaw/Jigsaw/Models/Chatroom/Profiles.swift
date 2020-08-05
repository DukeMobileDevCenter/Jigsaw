//
//  Profiles.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

class Profiles {
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
