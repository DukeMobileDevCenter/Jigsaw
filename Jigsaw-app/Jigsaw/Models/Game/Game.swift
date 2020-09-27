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
    /// Description detail text.
    let detailText: String
    /// Group 1 resource URL.
    let g1resURL: URL
    /// Group 2 resource URL.
    let g2resURL: URL
    /// Group 1 questionnaire.
    let g1Questionnaire: Questionnaire
    /// Group 2 questionnaire.
    let g2Questionnaire: Questionnaire
    /// Category, used for categorize games and display icon.
    let category: GameCategory
    /// Game card background image URL, can also use for styling.
    let backgroundImageURL: URL
    
    var gameID: String {
        gameName + "_" + String(level)
    }
    
    private var previousLevelGameID: String {
        let previousLevel = level - 1 > 0 ? level : 1
        return gameName + "_" + String(previousLevel)
    }
    
    /// Determine if a game/room is enabled for play.
    /// Enable all level 1 rooms as well as other unlocked rooms.
    var isEnabled: Bool {
        level == 1 || Profiles.playedGameIDs.contains(previousLevelGameID)
    }
    
    var isPlayed: Bool {
        Profiles.playedGameIDs.contains(gameID)
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard
            let version = data["version"] as? String,
            let level = data["level"] as? Int,
            let gameName = data["gameName"] as? String,
            let detailText = data["detailText"] as? String,
            let g1resURL = data["g1resURL"] as? String,
            let g2resURL = data["g2resURL"] as? String,
            let backgroundImageURL = data["backgroundImageURL"] as? String,
            let categoryString = data["category"] as? String,
            let category = GameCategory(rawValue: categoryString),
            let g1Questionnaire = data["g1Questionnaire"] as? [[String: Any]],
            let g2Questionnaire = data["g2Questionnaire"] as? [[String: Any]]
            else { return nil }
        
        self.version = version
        self.level = level
        self.gameName = gameName
        self.detailText = detailText
        self.g1resURL = URL(string: g1resURL)!
        self.g2resURL = URL(string: g2resURL)!
        self.backgroundImageURL = URL(string: backgroundImageURL)!
        self.category = category
        
        self.g1Questionnaire = Game.decodeQuestionnaireData(data: g1Questionnaire)
        self.g2Questionnaire = Game.decodeQuestionnaireData(data: g2Questionnaire)
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
