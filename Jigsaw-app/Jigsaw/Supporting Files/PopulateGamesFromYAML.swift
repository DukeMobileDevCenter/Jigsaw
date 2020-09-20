//
//  PopulateGamesFromYAML.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import Yams

class PopulateGamesFromYAML {
    static let shared = PopulateGamesFromYAML()
    private let filenames = ["usimmigration1", "usimmigration2", "law", "economy", "covid", "climate"]
    
    func uploadGame() {
        let paths = filenames.compactMap { Bundle.main.path(forResource: $0, ofType: "yml") }
        for path in paths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let data = try Yams.load(yaml: content) as? [String: Any]
                if let loadedDictionary = data {
                    // The game ID is gameName_level.
                    let gameID = loadedDictionary["gameName"] as! String + "_" + String((loadedDictionary["level"] as! Int))
                    FirebaseConstants.shared.games.document(gameID).setData(loadedDictionary)
                } else {
                    print("Error: cannot cast yaml to dictionary")
                }
            } catch {
                print(error)
            }
        }
    }
}
