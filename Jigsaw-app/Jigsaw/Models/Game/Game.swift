//
//  Game.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/8/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import FirebaseFirestore

struct Game {
    /// Game version.
    let version: String
    /// Game "room" level with natural index, i.e. starting from level 1.
    /// A room with higher level is unlocked after the completion of lower levels.
    let level: Int
    /// Name of the game.
    let gameName: String
    /// Description for the first page/preview page.
    let detailText: String
    /// Group 1 resource URLs.
    let group1resourceURLs: [URL]
    /// Group 2 resource URL.
    let group2resourceURLs: [URL]
    /// Group 1 questionnaires.
    let group1Questionnaires: [Questionnaire]
    /// Group 2 questionnaires.
    let group2Questionnaires: [Questionnaire]
    /// Category, used for categorize games and display icon.
    let category: GameCategory
    /// Game card background image URL, can also use for styling.
    let backgroundImageURL: URL
    
    var gameID: String {
        gameName + "_" + String(level)
    }
    
    private var previousLevelGameID: String {
        let previousLevel = level > 1 ? level - 1 : 1
        return gameName + "_" + String(previousLevel)
    }
    
    var nextLevelGameID: String {
        gameName + "_" + String(level + 1)
    }
    
    /// Determine if a game/room is enabled for play.
    /// Enable all level 1 rooms as well as other unlocked rooms.
    var isEnabled: Bool {
        level == 1 || Profiles.playedGameIDs.contains(previousLevelGameID)
    }
    
    /// Check if a game is played.
    /// - Note: This is not a good practice! A model struct should not rely on another object.
    var isPlayed: Bool {
        Profiles.playedGameIDs.contains(gameID)
    }
    
    init?(data: [String: Any]) {
        guard
            let version = data["version"] as? String,
            let level = data["level"] as? Int,
            let gameName = data["gameName"] as? String,
            let detailText = data["detailText"] as? String,
            let group1resourceURLs = data["group1resourceURLs"] as? [String],
            let group2resourceURLs = data["group2resourceURLs"] as? [String],
            let backgroundImageURL = data["backgroundImageURL"] as? String,
            let categoryString = data["category"] as? String,
            let category = GameCategory(rawValue: categoryString),  // Avoid unknown category.
            let group1Questionnaires = data["group1Questionnaires"] as? [[[String: Any]]],
            let group2Questionnaires = data["group2Questionnaires"] as? [[[String: Any]]]
        else { return nil }
        
        // Check if the game has correct amount of room content pairs.
        guard
            Set([group1resourceURLs.count,
                 group2resourceURLs.count,
                 group1Questionnaires.count,
                 group2Questionnaires.count]).count == 1
        else { return nil }
        
        self.version = version
        self.level = level
        self.gameName = gameName
        self.detailText = detailText
        self.group1resourceURLs = group1resourceURLs.compactMap { URL(string: $0) }
        self.group2resourceURLs = group2resourceURLs.compactMap { URL(string: $0) }
        self.backgroundImageURL = URL(string: backgroundImageURL)!
        self.category = category
        
        self.group1Questionnaires = group1Questionnaires.compactMap { Game.decodeQuestionnaireData(data: $0) }
        self.group2Questionnaires = group2Questionnaires.compactMap { Game.decodeQuestionnaireData(data: $0) }
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        self.init(data: data)
    }
    
    /// Decode an array of dictionaries to a questionnaire.
    ///
    /// - Parameter data: An array of `[String: Any]` dictionaries, aka `Array<Dictionary<String, Any>>`.
    /// - Returns: A `Questionnaire`, aka an array of questions which conform to `QuestionEssentialProperty` protocol.
    private static func decodeQuestionnaireData(data: [[String: Any]]) -> Questionnaire {
        return data.compactMap { questionDict in
            if let questionTypeString = questionDict["questionType"] as? String,
                let questionType = QuestionType(rawValue: questionTypeString) {
                let question: QuestionEssentialProperty?
                switch questionType {
                case .instruction:
                    question = InstructionQuestion(data: questionDict)
                case .singleChoice:
                    question = SingleChoiceQuestion(data: questionDict)
                case .multipleChoice:
                    question = MultipleChoiceQuestion(data: questionDict)
                case .numeric:
                    question = NumericQuestion(data: questionDict)
                case .scale:
                    question = ScaleQuestion(data: questionDict)
                case .boolean:
                    question = BooleanQuestion(data: questionDict)
                case .unknown:
                    question = nil
                }
                return question
            } else {
                return nil
            }
        }
    }
}
