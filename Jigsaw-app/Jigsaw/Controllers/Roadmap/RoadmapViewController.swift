//
//  RoadmapViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import ResearchKit

class RoadmapViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func radarChartButtonTapped(_ sender: UIButton) {
        let controller = GameHistoryRadarChartViewController()
        controller.hidesBottomBarWhenPushed = true
        show(controller, sender: sender)
    }
}
