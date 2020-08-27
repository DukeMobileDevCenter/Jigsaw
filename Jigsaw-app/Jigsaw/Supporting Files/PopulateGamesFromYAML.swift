//
//  PopulateGamesFromYAML.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/24/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Yams

class PopulateGamesFromYAML {
    static let shared = PopulateGamesFromYAML()
    
    private let gameNames = ["usimmigration1", "usimmigration2", "education", "housing", "medicare", "IRS"]
    
    func uploadGame() {
        let database = Firestore.firestore()
        let paths = gameNames.compactMap { Bundle.main.path(forResource: $0, ofType: "yml") }
        for path in paths {
            do {
                let content = try String(contentsOfFile: path, encoding: .utf8)
                let data = try Yams.load(yaml: content) as? [String: Any]
                if let loadedDictionary = data {
                    database.collection("Games2").document(loadedDictionary["gameName"] as! String).setData(loadedDictionary)
                } else {
                    print("cannot cast yaml to dictionary")
                }
            } catch {
                print(error)
            }
        }
    }
}
