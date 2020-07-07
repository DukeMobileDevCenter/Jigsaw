//
//  LoginViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit

class LoginViewController: UIViewController {
    @IBAction func startOverWelcomePage(_ sender: Any) {
        let questionnaireSchemaURL = URL(string: "https://people.duke.edu/~tc233/hosted_files/questionnaire_v1.json")!
        Questionnaire.load(fromURL: questionnaireSchemaURL) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let questionnaire):
                let task = self.createSurveyTaskFromJson(q: questionnaire)
                DispatchQueue.main.async {
                    let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
                    taskViewController.delegate = self
                    taskViewController.modalPresentationStyle = .fullScreen
                    taskViewController.navigationBar.prefersLargeTitles = false
                    self.show(taskViewController, sender: sender)
                }
            case .failure(let error):
                DispatchQueue.main.async { self.presentAlert(error: error) }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    /// this is the function to create the surveytask from the Questionnaire class (parsed from json)
    ///
    /// - Parameter q: Questionnaire class object
    /// - Returns: an ORKOrderedTask surveyTask
    func createSurveyTaskFromJson(q: Questionnaire) -> ORKOrderedTask {
        var steps = [ORKStep]()
        print("debug info: the version of questionnaire is \(q.version)")
        for question in q.questions {
            switch question.questionType {
            case .instruction:
                steps.append(QuestionSteps.instructionStep(question: question))
            case .multipleChoice:
                steps.append(QuestionSteps.multipleChoiceStep(question: question))
            case .singleChoice:
                steps.append(QuestionSteps.singleChoiceStep(question: question))
            case .numeric:
                steps.append(QuestionSteps.numericStep(question: question))
            case .map:
                steps.append(QuestionSteps.mapStep(question: question))
            case .scale:
                steps.append(QuestionSteps.scaleStep(question: question))
            case .unknown:
                print("debug info: i've no idea what is this. unidentified type")
                continue
            }
        }
        // completion instruction
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Survey Complete"
        completionStep.text = "Your answers will reflect our provided choices."
        steps.append(completionStep)
        return ORKOrderedTask(identifier: "surveyTask", steps: steps)
    }
}

extension LoginViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .saved, .failed:
            taskViewController.dismiss(animated: true)
            if let error = error { presentAlert(error: error) }
        case .completed:
            print("✅ completed")
            print(taskViewController.result)
            taskViewController.dismiss(animated: true)
        default:
            return
        }
    }
}
