//
//  AppInfo.swift
//  Jigsaw
//
//  Created by Ting Chen on 9/26/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

enum AppInfo {
    static let appName = Bundle.main.object(forInfoDictionaryKey: kCFBundleNameKey as String) as! String
    static let versionNumber = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    static let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
}
