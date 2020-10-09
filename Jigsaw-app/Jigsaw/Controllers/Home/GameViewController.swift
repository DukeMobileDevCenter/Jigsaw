//
//  GameViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

class GameViewController: ORKTaskViewController {
    private let game: GameOfGroup
    
    init(game: GameOfGroup, taskRun taskRunUUID: UUID? = nil) {
        self.game = game
        super.init(task: nil, taskRun: taskRunUUID)
        task = createSurveyTask(from: game.questionnaire)
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var welcomeStep: ORKInstructionStep {
        let welcomeStep = ORKInstructionStep(identifier: "Introduction")
        welcomeStep.title = game.gameName
        welcomeStep.detailText = game.detailText
        welcomeStep.iconImage = UIImage(systemName: "info.circle")!
        return welcomeStep
    }
    
    private let chatroomCountdownStep: ORKActiveStep = {
        let step = ORKActiveStep(identifier: "Countdown")
        step.stepDuration = TimeInterval(integerLiteral: 240)
        step.shouldUseNextAsSkipButton = true
        step.shouldContinueOnFinish = true
        step.shouldShowDefaultTimer = true
        step.shouldStartTimerAutomatically = true
        step.shouldSpeakRemainingTimeAtHalfway = true
        step.shouldSpeakCountDown = true
        return step
    }()
    
    private let questionsInstructionStep: ORKInstructionStep = {
        let questionsInstructionStep = ORKInstructionStep(identifier: "QuestionsInstruction")
        questionsInstructionStep.title = "Quiz"
        questionsInstructionStep.detailText = "You can escape this room if your team answers all of the following questions correctly. Good luck!"
        questionsInstructionStep.iconImage = UIImage(systemName: "exclamationmark.square")
        questionsInstructionStep.isOptional = false
        return questionsInstructionStep
    }()
    
    private let waitStep: ORKWaitStep = {
        let step = ORKWaitStep(identifier: "Wait")
        step.indicatorType = .progressBar
        step.title = "Please wait"
        step.detailText = "Please wait for other players to finish."
        return step
    }()

    /// Create an `ORKOrderedTask` from the a questionnaire.
    ///
    /// - Parameter questionnaire: A `Questionnaire`, which is an array of questions.
    /// - Returns: An `ORKOrderedTask` surveyTask.
    private func createSurveyTask(from questionnaire: Questionnaire) -> ORKNavigableOrderedTask {
        var steps = [ORKStep]()
        
        // Welcome instruction step.
        steps.append(welcomeStep)
        
        // Resource reading page.
        let webStep = ORKWebViewStep(identifier: "Resource", url: game.resourceURL)
        steps.append(webStep)
        
        // Chatroom step.
        steps.append(chatroomCountdownStep)
        
        // Questions instructions step.
        steps.append(questionsInstructionStep)
        
        for question in questionnaire {
            switch question.questionType {
            case .instruction:
                steps.append(QuestionStepsModel.instructionStep(question: question as! InstructionQuestion))
            case .multipleChoice:
                steps.append(QuestionStepsModel.multipleChoiceStep(question: question as! MultipleChoiceQuestion))
            case .singleChoice:
                steps.append(QuestionStepsModel.singleChoiceStep(question: question as! SingleChoiceQuestion))
            case .numeric:
                steps.append(QuestionStepsModel.numericStep(question: question as! NumericQuestion))
            case .boolean:
                steps.append(QuestionStepsModel.booleanStep(question: question as! BooleanQuestion))
            case .scale:
                steps.append(QuestionStepsModel.scaleStep(question: question as! ScaleQuestion))
            case .unknown:
                print("debug info: i've no idea what is this. unidentified type")
                continue
            }
        }
        
        // Wait step
        steps.append(waitStep)
        
        // Completion instruction.
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Game complete"
        completionStep.text = "Your answers will be logged in game history."
        steps.append(completionStep)
        let task = ORKNavigableOrderedTask(identifier: "surveyTask", steps: steps)
        return task
    }
}
