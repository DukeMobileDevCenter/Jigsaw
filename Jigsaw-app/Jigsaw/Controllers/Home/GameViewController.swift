//
//  GameViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit
import Down

class GameViewController: ORKTaskViewController {
    private let game: GameOfGroup
    
    init(game: GameOfGroup, currentRoom: Int, taskRun taskRunUUID: UUID? = nil) {
        self.game = game
        super.init(task: nil, taskRun: taskRunUUID)
        task = createSurveyTask(from: game, currentRoom: currentRoom)
    }
    // IM a comment, have mercy
    
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var chatroomInstructionStep: ORKInstructionStep {
        let step = ORKInstructionStep(identifier: "ChatroomInstruction")
        step.title = "Chatroom"
        step.detailText =
        """
        Hi team! You can now chat about what you've just seen.
        Remember that different team members have seen different pieces of information, and the whole team needs to know about all of these pieces in order to escape to the next room.
        """
        step.iconImage = UIImage(systemName: "bubble.left.and.bubble.right")!
        return step
    }
    
    private let chatroomCountdownStep: ORKActiveStep = {
        let step = ORKActiveStep(identifier: "Countdown")
//        step.stepDuration = TimeInterval(integerLiteral: 240)
//        step.shouldShowDefaultTimer = true
//        step.shouldStartTimerAutomatically = true
//        step.shouldUseNextAsSkipButton = true
        step.shouldContinueOnFinish = true
        return step
    }()
    
    private let questionsInstructionStep: ORKInstructionStep = {
        let step = ORKInstructionStep(identifier: "QuestionsInstruction")
        step.title = "Quiz"
        step.detailText = "You will now be quizzed on the information you and your teammate just shared.\nYou can escape this room if your team answers all of the following questions correctly.\nLet's go!🤠"
        step.iconImage = UIImage(systemName: "exclamationmark.square")
        return step
    }()
    
    private let waitStep: ORKWaitStep = {
        let step = ORKWaitStep(identifier: "Wait")
        step.indicatorType = .progressBar
        step.title = "Please Wait"
        step.detailText = "Please wait for other players to finish."
        return step
    }()
    
    /// Create an `ORKOrderedTask` from the a game.
    ///
    /// - Parameters:
    ///   - game: A `GameOfGroup` that contains a series of room content.
    ///   - currentRoom: The current room (sub-level) of the current game.
    /// - Returns: An `ORKOrderedTask` surveyTask.
    private func createSurveyTask(from game: GameOfGroup, currentRoom: Int) -> ORKNavigableOrderedTask {
        var steps = [ORKStep]()
        
        // Resource reading page.
        let promptStep = ORKInstructionStep(identifier: "Resource")
        promptStep.detailText = "Please read the following statement carefully. Once you move on, you will not be able to view it again.\n\n\(game.resourceContent[currentRoom])"
        steps.append(promptStep)

        // Chatroom instruction step.
        steps.append(chatroomInstructionStep)
        
        // Chatroom step.
        steps.append(chatroomCountdownStep)
        
        // Questions instructions step.
        steps.append(questionsInstructionStep)
        
        for question in game.questionnaires[currentRoom] {
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
            case .continuousScale:
                steps.append(QuestionStepsModel.continuousScaleStep(question: question as! ContinuousScaleQuestion))
            case .unknown:
                continue
            }
        }
        
        // Wait step
        steps.append(waitStep)
        
        // Completion instruction.
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Room Escaped 🎉"
        // Add 1 to current room to display human readable index.
        completionStep.text = "Congratulations on escaping from Room \(currentRoom + 1).\nKeep going!"
        steps.append(completionStep)
        let task = ORKNavigableOrderedTask(identifier: "surveyTask", steps: steps)
        return task
    }
}
