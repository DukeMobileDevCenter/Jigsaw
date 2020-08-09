//
//  QuestionnaireTaskViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

class QuestionnaireTaskViewController: ORKTaskViewController {
    init(questionnaire: Questionnaire, taskRun taskRunUUID: UUID?) {
        super.init(task: nil, taskRun: taskRunUUID)
        self.task = self.createSurveyTaskFromJson(questionnaire: questionnaire)
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// this is the function to create the surveytask from the Questionnaire class (parsed from json)
    ///
    /// - Parameter q: Questionnaire class object
    /// - Returns: an ORKOrderedTask surveyTask
    func createSurveyTaskFromJson(questionnaire: Questionnaire) -> ORKOrderedTask {
        var steps = [ORKStep]()
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
        
        // completion instruction
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Survey Complete"
        completionStep.text = "Your answers will reflect our provided choices."
        steps.append(completionStep)
        return ORKOrderedTask(identifier: "surveyTask", steps: steps)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension QuestionnaireTaskViewController: ORKReviewViewControllerDelegate {
    func reviewViewController(_ reviewViewController: ORKReviewViewController, didUpdate updatedResult: ORKTaskResult, source resultSource: ORKTaskResult) {
        print("✅ updatedResult")
    }
    
    func reviewViewControllerDidSelectIncompleteCell(_ reviewViewController: ORKReviewViewController) {
        print("✅ incompleted cell selected")
    }
}
