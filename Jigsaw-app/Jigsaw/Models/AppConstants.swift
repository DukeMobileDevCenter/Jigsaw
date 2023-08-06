//
//  AppConstants.swift
//  Jigsaw
//
//  Created by Ting Chen on 10/14/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import Foundation

/// A static enum to keep information that would be shared among the app.
enum AppConstants {
    /// The URL of feedback Google Forms.
    static let feedbackFormURL = URL(string: Strings.AppConstants.AppConstants.feedbackFormURL)!
    static let surveyURL = URL(string: Strings.AppConstants.AppConstants.surveyURL)!
    static let contactDeveloperURL = URL(string: Strings.AppConstants.AppConstants.contactDeveloperURL!)
    
    /// A style sheet for displaying detail instruction text as well as preview text.
    static let simpleStylesheet =
        """
        body { font: -apple-system-body }
        h1 { font: -apple-system-title1 }
        h2 { font: -apple-system-title2 }
        h3 { font: -apple-system-title3 }
        h4, h5, h6 { font: -apple-system-headline }
        """
    
    static let darkModeStylesheet =
        """
        body { font: -apple-system-body; color: white }
        h1 { font: -apple-system-title1 }
        h2 { font: -apple-system-title2 }
        h3 { font: -apple-system-title3 }
        h4, h5, h6 { font: -apple-system-headline }
        """
}
