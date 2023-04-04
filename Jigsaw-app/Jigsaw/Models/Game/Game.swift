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
    /// Name of the game.
    let gameName: String
    /// Category or topic, used for categorize games and display icon.
    let category: GameCategory
    /// Game version.
    let version: String
    /// Game "room" level with natural index, i.e. starting from level 1.
    /// A room with higher level is unlocked after the completion of lower levels.
    let level: Int
    /// The maximal attempts for a each room in a game.
    let maxAttempts: Int
    /// Description for the first page/preview page.
    let detailText: String
    /// Topic introduction text
    let introductionText: String
    /// Game card background image URL, can also use for styling.
    let backgroundImageURL: URL
    /// Group 1 resource contents (markdown).
    let group1resourceContents: [String]
    /// Group 2 resource URL.
    let group2resourceContents: [String]
    /// Group 1 questionnaires.
    let group1Questionnaires: [Questionnaire]
    /// Group 2 questionnaires.
    let group2Questionnaires: [Questionnaire]
    
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
            let version = data[Strings.Game.Init.version] as? String,
            let level = data[Strings.Game.Init.level] as? Int,
            let maxAttempts = data[Strings.Game.Init.maxAttempts] as? Int,
            let gameName = data[Strings.Game.Init.gameName] as? String,
            let detailText = data[Strings.Game.Init.detailText] as? String,
            let introductionText = data[Strings.Game.Init.introductionText] as? String,
            let group1resourceContents = data[Strings.Game.Init.group1resourceContents] as? [String],
            let group2resourceContents = data[Strings.Game.Init.group2resrouceContents] as? [String],
            let backgroundImageURL = data[Strings.Game.Init.backgroundImageURL] as? String,
            let categoryString = data[Strings.Game.Init.categoryString] as? String,
            let category = GameCategory(rawValue: categoryString),  // Avoid unknown category.
            let group1Questionnaires = data[Strings.Game.Init.group1Questionnaires] as? [[[String: Any]]],
            let group2Questionnaires = data[group2Questionnaires] as? [[[String: Any]]]
        else { return nil }
        
        // Check if the game has correct amount of room content pairs.
        guard
            Set([group1resourceContents.count,
                 group2resourceContents.count,
                 group1Questionnaires.count,
                 group2Questionnaires.count]).count == 1
        else { return nil }
        
        self.version = version
        self.level = level
        self.maxAttempts = maxAttempts
        self.gameName = gameName
        self.detailText = detailText
        self.group1resourceContents = group1resourceContents
        self.group2resourceContents = group2resourceContents
        self.backgroundImageURL = URL(string: backgroundImageURL)!
        self.category = category
        self.introductionText = introductionText
        
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
                case .continuousScale:
                    question = ContinuousScaleQuestion(data: questionDict)
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
