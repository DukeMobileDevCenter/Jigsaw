//
//  GameResult.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/29/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation
import ResearchKit

struct GameResult {
    let taskResults: [ORKTaskResult]
    let questionnaires: [Questionnaire]
    
    var resultPairs: KeyValuePairs<AnswerCategory, Int> {
        // If a question is skipped, it has a result but the answer is nil.
        var skipped = 0
        var correct = 0
        var incorrect = 0
        var unknown = 0
        // Calculate the result based on how many rooms are played.
        // For example, a player reached room 3 but failed there, then there are 3 task results,
        // so the result pairs are calculated based on the first 3 questionnaires in the game.
        let roomsCount = taskResults.count
        for (taskResult, questionnaire) in zip(taskResults, questionnaires[..<roomsCount]) {
            for question in questionnaire {
                if question.questionType == .instruction {
                    // Instruction result is always empty.
                    continue
                }
                guard let result = taskResult.stepResult(forStepIdentifier: question.title)?.results?.first else {
                    continue
                }
                // Judge if the answer is correct from the correct answer in questionnaire
                // and the player result from game.
                let outcome = judgeAnswer(question: question, result: result)
                // Sum up the stats.
                switch outcome {
                case .correct:
                    correct += 1
                case .skipped:
                    skipped += 1
                case .incorrect:
                    incorrect += 1
                case .unknown:
                    unknown += 1
                }
            }
        }
        return [.correct: correct, .skipped: skipped, .incorrect: incorrect, .unknown: unknown]
    }
    
    var summary: String {
        """
        Correct: \(resultPairs[0].1)
        Skipped: \(resultPairs[1].1)
        Incorrect: \(resultPairs[2].1)
        """
    }
    
    var score: Double {
        let total: Int = resultPairs
            .map { key, value in
                switch key {
                case .correct, .incorrect, .skipped:
                    // 3 points for answers that have correct answer.
                    return 3 * value
                case .unknown:
                    // 0 point for unknown answer, should not happen.
                    return 0
                }
            }
            .reduce(0, +)
        let scored: Int = resultPairs[0].1 * 3 + resultPairs[1].1 * 1
        return total != 0 ? Double(scored) / Double(total) : 0
    }
    
    var isPassed: Bool {
        score > 0.75
    }
    
    var wrongCount: Int {
        // Incorrect is the third case.
        resultPairs[2].1
    }
    
    // swiftlint:disable cyclomatic_complexity function_body_length
    
    /// Judge if the player answer the question correctly.
    ///
    /// - Parameters:
    ///   - question: The original question in questionnaire, which contains the correct answer.
    ///   - result: The player's answer from the game.
    /// - Returns: An `AnswerCategory` case.
    private func judgeAnswer(question: QuestionEssentialProperty, result: ORKResult) -> AnswerCategory {
        let outcome: AnswerCategory
        switch question.questionType {
        case .multipleChoice:
            guard let answers = (result as? ORKChoiceQuestionResult)?.choiceAnswers else {
                return .skipped
            }
            let correctAnswers = (question as? MultipleChoiceQuestion)?.correctAnswers
            outcome = answers.map { ($0 as? String)! } == correctAnswers ? .correct : .incorrect
        case .singleChoice:
            guard let answer = (result as? ORKChoiceQuestionResult)?.choiceAnswers?.first else {
                return .skipped
            }
            let correctAnswer = (question as? SingleChoiceQuestion)?.correctAnswer
            outcome = (answer as? String) == correctAnswer ? .correct : .incorrect
        case .numeric:
            guard let answer = (result as? ORKNumericQuestionResult)?.numericAnswer else {
                return .skipped
            }
            guard let correctMin = (question as? NumericQuestion)?.correctMinValue,
                let correctMax = (question as? NumericQuestion)?.correctMaxValue else {
                    return .unknown
            }
            outcome = (correctMin...correctMax).contains(answer.doubleValue) ? .correct : .incorrect
        case .boolean:
            guard let answer = (result as? ORKBooleanQuestionResult)?.booleanAnswer else {
                return .skipped
            }
            let correctAnswer = (question as? BooleanQuestion)?.correctAnswer
            outcome = correctAnswer == Bool(exactly: answer) ? .correct : .incorrect
        case .scale:
            guard let answer = (result as? ORKScaleQuestionResult)?.scaleAnswer else {
                return .skipped
            }
            guard let correctMin = (question as? ScaleQuestion)?.correctMinValue,
                let correctMax = (question as? ScaleQuestion)?.correctMaxValue else {
                    return .unknown
            }
            outcome = (correctMin...correctMax).contains(answer.intValue) ? .correct : .incorrect
        case .continuousScale:
            guard let answer = (result as? ORKScaleQuestionResult)?.scaleAnswer else {
                return .skipped
            }
            guard let correctMin = (question as? ContinuousScaleQuestion)?.correctMinValue,
                let correctMax = (question as? ContinuousScaleQuestion)?.correctMaxValue else {
                    return .unknown
            }
            outcome = (correctMin...correctMax).contains(answer.intValue) ? .correct : .incorrect
        case .unknown, .instruction:
            // Instruction should never come here.
            return .unknown
        }
        return outcome
    }
    // swiftlint:enable cyclomatic_complexity function_body_length
}
