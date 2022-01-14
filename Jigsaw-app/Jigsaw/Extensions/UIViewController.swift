//
//  UIViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/6/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit

extension UIViewController {
    /// Shows an alert with the given title, message, and an OK button.
    ///
    /// - Parameters:
    ///   - title: The title string of the alert.
    ///   - message: The message string of the alert.
    func presentAlert(title: String? = nil, message: String? = nil) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert, actions: [okAction])
        present(alertController, animated: true)
    }
    
    /// Show an alert with the title "Error", the error's `localizedDescription` as the message, and an OK button.
    ///
    /// - Parameter error: The error to show.
    func presentAlert(error: Error) {
        presentAlert(title: "Error", message: error.localizedDescription)
    }
    
    func presentAlert(gameError: GameError) {
        let okAction = UIAlertAction(title: "OK", style: .default)
        let alertController = UIAlertController(title: "Uh-oh!", message: gameError.description, preferredStyle: .alert, actions: [okAction])
        if let controller = presentedViewController {
            // Dismiss existing alert before present.
            controller.dismiss(animated: false, completion: { [weak self] in self?.present(alertController, animated: true) })
        } else {
            present(alertController, animated: true)
        }
    }
}

private extension UIAlertController {
    /// Initializes the alert controller with the given parameters, adding the
    /// actions successively and setting the first action as preferred.
    convenience init(title: String? = nil, message: String? = nil, preferredStyle: UIAlertController.Style = .alert, actions: [UIAlertAction] = []) {
        self.init(title: title, message: message, preferredStyle: preferredStyle)
        for action in actions {
            addAction(action)
        }
        preferredAction = actions.first
    }
}
