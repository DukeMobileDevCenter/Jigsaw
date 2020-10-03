//
//  MetricsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 7/25/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import GameKit
import ResearchKit

class MetricsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        GameCenterHelper.shared.viewController = self
    }
    
    @IBAction func metricsButtonTapped(_ sender: UIButton) {
        let controller = UIStoryboard(name: "GameHistoryRadarChartViewController", bundle: .main).instantiateInitialViewController() as! GameHistoryRadarChartViewController
        controller.hidesBottomBarWhenPushed = true
        show(controller, sender: sender)
    }
    
    @IBAction func profilesButtonTapped(_ sender: UIButton) {
    }
}
