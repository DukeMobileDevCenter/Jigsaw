//
//  PopulateGamesFromYAML.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import Yams

class PopulateGamesFromYAML {
    static let shared = PopulateGamesFromYAML()
    private let database = Firestore.firestore()
    private let gameNames = ["usimmigration1", "usimmigration2", "education", "housing-dilemma", "medicare", "IRS trivia"]
    
    func uploadGame() {
        let paths = gameNames.compactMap { Bundle.main.path(forResource: $0, ofType: "yml") }
        for path in paths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let data = try Yams.load(yaml: content) as? [String: Any]
                if let loadedDictionary = data {
                    database.collection("Games").document(loadedDictionary["gameName"] as! String).setData(loadedDictionary)
                } else {
                    print("Error: cannot cast yaml to dictionary")
                }
            } catch {
                print(error)
            }
        }
    }
}
