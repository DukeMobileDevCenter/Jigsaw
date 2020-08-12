//
//  Onboarding.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit
import FirebaseFirestore

protocol OnboardingManagerDelegate: AnyObject {
    func didCompleteOnboarding()
}

class OnboardingViewController: ORKTaskViewController {
    weak var onboardingManagerDelegate: OnboardingManagerDelegate?
    
    init(taskRun taskRunUUID: UUID?) {
        super.init(task: OnboardingViewController.getTask(), taskRun: taskRunUUID)
    }
    
    @available(*, unavailable)
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
            OnboardingSteps.profileStep,
            OnboardingSteps.completionStep
        ])
        return steps
    }
    
    private static func getTask() -> ORKOrderedTask {
        // completion instruction
        let steps = makeInstructionSteps()
        return ORKOrderedTask(identifier: "InstructionTaskIdentifier", steps: steps)
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
//            print("✅ completed")
            if let sliderResult = taskViewController.result.stepResult(forStepIdentifier: "PoliticalSliderStep")?.results?.first as? ORKScaleQuestionResult,
                let answer = sliderResult.scaleAnswer {
                Profiles.jigsawValue = answer.doubleValue
            } else {
                // Never arrives here.
                fatalError("Error: Jigsaw slider value not provided.")
            }
            if let displayNameResult = taskViewController.result.stepResult(forStepIdentifier: "DisplayNameStep")?.results?.first as? ORKTextQuestionResult,
                let answer = displayNameResult.textAnswer {
                Profiles.displayName = answer
            } else {
                Profiles.displayName = "AnonymUser"
            }
            createUserInfo(userID: Profiles.userID, displayName: Profiles.displayName, jigsawValue: Profiles.jigsawValue)
            presentingViewController?.dismiss(animated: true)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
    
    private func createUserInfo(userID: String, displayName: String, jigsawValue: Double) {
        // Update the database here. Fill in the 2 fields, and left blank the others.
        let player = Player(
            userID: userID,
            displayName: displayName,
            jigsawValue: jigsawValue,
            joinDate: Date(),
            gameHistory: [],
            email: nil,
            demographics: [String: String]()
        )
        let db = Firestore.firestore()
        do {
            try db.collection("Players").document(userID).setData(from: player)
        } catch {
            presentAlert(error: error)
        }
    }
}
