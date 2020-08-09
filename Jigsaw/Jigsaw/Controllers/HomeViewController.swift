//
//  HomeViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/3/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit

class HomeViewController: UIViewController {
    var reviewVC: ORKReviewViewController!
    
    @IBAction func startOverWelcomePage(_ sender: UIButton) {
        if QuestionnaireStore.shared.isLoaded {
            let questionnaire = QuestionnaireStore.shared.allQuestionnaires.first!
            let taskViewController = QuestionnaireTaskViewController(questionnaire: questionnaire, taskRun: nil)
            taskViewController.delegate = self
            show(taskViewController, sender: sender)
        }
    }
    
    @IBAction func testBarButtonTapped(_ sender: UIBarButtonItem) {
//        show(reviewVC, sender: sender)
//        let vc = ChatViewController(user: currentUser, chatroom: "zY40mIdv1xnSxyB9GVPK")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
}

extension HomeViewController: ORKTaskViewControllerDelegate {
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        switch reason {
        case .discarded, .failed, .saved:
            if let error = error { presentAlert(error: error) }
            taskViewController.dismiss(animated: true)
        case .completed:
            // Access the first and last name from the review step
            //            if let signatureResult = signatureResult(taskViewController: taskViewController),
            //                let signature = signatureResult.signature {
            //                let defaults = UserDefaults.standard
            //                defaults.set(signature.givenName, forKey: "firstName")
            //                defaults.set(signature.familyName, forKey: "lastName")
            //            }
            
            print("✅ completed")
            print(taskViewController.result)
            taskViewController.dismiss(animated: true, completion: nil)
        @unknown default:
            fatalError("Error: Onboarding task yields unknown result.")
        }
    }
}

extension HomeViewController: ORKReviewViewControllerDelegate {
    func reviewViewController(_ reviewViewController: ORKReviewViewController, didUpdate updatedResult: ORKTaskResult, source resultSource: ORKTaskResult) {
        print("✅ updatedResult")
    }
    
    func reviewViewControllerDidSelectIncompleteCell(_ reviewViewController: ORKReviewViewController) {
        print("✅ incompleted cell selected")
    }
}
