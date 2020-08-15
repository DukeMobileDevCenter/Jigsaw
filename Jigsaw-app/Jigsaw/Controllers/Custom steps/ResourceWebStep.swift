//
//  ResourceWebStep.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/9/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import ResearchKit

class ResourceWebStep: ORKStep {
    override class func stepViewControllerClass() -> AnyClass {
        return ResourceWebStepViewController.classForCoder()
    }
    
    var url: URL?
    
    init(identifier: String, url: URL) {
        super.init(identifier: identifier)
        self.url = url
    }
    
    @available(*, unavailable)
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
