//
//  GameViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

class GameViewController: ORKTaskViewController {
    var resourceURL: URL!
    
    init(game: GameOfGroup, taskRun taskRunUUID: UUID?) {
        super.init(task: nil, taskRun: taskRunUUID)
        resourceURL = URL(string: game.resourceURL)!
        task = self.createSurveyTaskFromJson(questionnaire: game.questionnaire)
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let chatroomCountdownStep: ORKActiveStep = {
        let step = ORKActiveStep(identifier: "Countdown")
        step.stepDuration = TimeInterval(integerLiteral: 30)
        step.shouldUseNextAsSkipButton = true
        step.shouldContinueOnFinish = true
        step.shouldShowDefaultTimer = true
        step.shouldStartTimerAutomatically = true
        step.shouldSpeakRemainingTimeAtHalfway = true
        step.shouldSpeakCountDown = true
        return step
    }()

    /// The function to create the surveytask from the Questionnaire class (parsed from json)
    ///
    /// - Parameter questionnaire: Questionnaire type, which is an array of questions.
    /// - Returns: an `ORKOrderedTask` surveyTask.
    func createSurveyTaskFromJson(questionnaire: Questionnaire) -> ORKOrderedTask {
        var steps = [ORKStep]()
        
        // Welcome step
        let welcomeStep = ORKInstructionStep(identifier: "Welcome")
        welcomeStep.title = "Welcome"
        welcomeStep.detailText = "This is a game blah blah."
        welcomeStep.image = UIImage(named: "onboarding_jigsaw")!
        steps.append(welcomeStep)
        
        // Resource reading page
        let readingsStep = ResourceWebStep(identifier: "Resource", url: resourceURL)
        steps.append(readingsStep)
        
        steps.append(chatroomCountdownStep)
        
        let questionsInstructionStep = ORKInstructionStep(identifier: "Questions")
        questionsInstructionStep.title = "Required Questions"
        questionsInstructionStep.detailText = "The following questions are essential. Please answer carefully."
        questionsInstructionStep.iconImage = UIImage(systemName: "exclamationmark.square")
        questionsInstructionStep.isOptional = false
        steps.append(questionsInstructionStep)
        
        for question in questionnaire {
            switch question.questionType {
            case .instruction:
                steps.append(QuestionStepsModel.instructionStep(question: question))
            case .multipleChoice:
                steps.append(QuestionStepsModel.multipleChoiceStep(question: question))
            case .singleChoice:
                steps.append(QuestionStepsModel.singleChoiceStep(question: question))
            case .numeric:
                steps.append(QuestionStepsModel.numericStep(question: question))
//            case .map:
//                steps.append(QuestionStepsModel.mapStep(question: question))
            case .scale:
                steps.append(QuestionStepsModel.scaleStep(question: question))
            case .unknown:
                print("debug info: i've no idea what is this. unidentified type")
                continue
            default:
                break
            }
        }
        
        // Completion instruction.
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Game complete"
        completionStep.text = "Your answers will be logged in game history."
        steps.append(completionStep)
        return ORKOrderedTask(identifier: "surveyTask", steps: steps)
    }
}

extension GameViewController: ORKReviewViewControllerDelegate {
    func reviewViewController(_ reviewViewController: ORKReviewViewController, didUpdate updatedResult: ORKTaskResult, source resultSource: ORKTaskResult) {
        print("✅ updatedResult")
    }
    
    func reviewViewControllerDidSelectIncompleteCell(_ reviewViewController: ORKReviewViewController) {
        print("✅ incompleted cell selected")
    }
}
