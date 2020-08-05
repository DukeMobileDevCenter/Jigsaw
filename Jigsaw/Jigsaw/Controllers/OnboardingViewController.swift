//
//  Onboarding.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

protocol OnboardingManagerDelegate: AnyObject {
    func didCompleteOnboarding()
}

class OnboardingViewController: ORKTaskViewController {
    weak var onboardingManagerDelegate: OnboardingManagerDelegate?
    
    init(taskRun taskRunUUID: UUID?) {
        super.init(task: OnboardingViewController.getTask(), taskRun: taskRunUUID)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }
    
    private static func makeInstructionSteps() -> [ORKStep] {
        var steps = [ORKStep]()
        steps.append(contentsOf: [
            OnboardingSteps.instructionStep,
            OnboardingSteps.informedConsentInstructionStep,
            OnboardingSteps.politicalSliderStep,
            OnboardingSteps.profileStep
        ])
        let completionStep = ORKOrderedTask.makeCompletionStep()
        completionStep.title = "Complete"
        completionStep.text = "Please start to explore the world of Jigsaw."
        steps.append(completionStep)
        return steps
    }
    
    private static func getTask() -> ORKNavigableOrderedTask {
        // completion instruction
        let steps = makeInstructionSteps()
        return ORKNavigableOrderedTask(identifier: "InstructionTaskIdentifier", steps: steps)
    }
}

extension OnboardingViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed, .saved:
            if let error = error { presentAlert(error: error) }
            presentingViewController?.dismiss(animated: false)
        case .completed:
            OnboardingStateManager.shared.setOnboardingCompletedState(state: true)
            // Access the first and last name from the review step
//            if let signatureResult = signatureResult(taskViewController: taskViewController),
//                let signature = signatureResult.signature {
//                let defaults = UserDefaults.standard
//                defaults.set(signature.givenName, forKey: "firstName")
//                defaults.set(signature.familyName, forKey: "lastName")
//            }
            print("✅ completed")
            print(taskViewController.result)
            presentingViewController?.dismiss(animated: true, completion: nil)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}
