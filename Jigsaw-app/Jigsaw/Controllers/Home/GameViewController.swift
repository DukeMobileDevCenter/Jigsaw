//
//  GameViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

class GameViewController: ORKTaskViewController {
    private var resourceURL: URL!
    
    init(game: GameOfGroup, taskRun taskRunUUID: UUID?) {
        super.init(task: nil, taskRun: taskRunUUID)
        resourceURL = game.resourceURL
        task = createSurveyTask(from: game.questionnaire)
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

    /// Create an `ORKOrderedTask` from the a questionnaire.
    ///
    /// - Parameter questionnaire: A `Questionnaire`, which is an array of questions.
    /// - Returns: An `ORKOrderedTask` surveyTask.
    private func createSurveyTask(from questionnaire: Questionnaire) -> ORKOrderedTask {
        var steps = [ORKStep]()
        
        // Welcome step.
        let welcomeStep = ORKInstructionStep(identifier: "Welcome")
        welcomeStep.title = "Welcome"
        welcomeStep.detailText = "This is a game blah blah."
        welcomeStep.image = UIImage(named: "onboarding_jigsaw")!
        steps.append(welcomeStep)
        
        // Resource reading page.
        let readingsStep = ResourceWebStep(identifier: "Resource", url: resourceURL)
        steps.append(readingsStep)
        
        // Chatroom step.
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
        
        // Completion instruction.
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Game complete"
        completionStep.text = "Your answers will be logged in game history."
        steps.append(completionStep)
        return ORKOrderedTask(identifier: "surveyTask", steps: steps)
    }
}
