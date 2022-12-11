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
import Charts
import ProgressHUD

class MetricsViewController: UIViewController, AxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return categoryLabels[Int(value) % categoryLabels.count]
    }
    
    @IBOutlet var chartView: RadarChartView!
    
    @IBOutlet var achievementsButton: UIButton! {
        didSet {
            achievementsButton.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet var leaderboardButton: UIButton! {
        didSet {
            leaderboardButton.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet var teamRankingsButton: UIButton! {
        didSet {
            teamRankingsButton.layer.cornerRadius = 8
        }
    }
    
    /// All category labels except Random.
    private let categoryLabels = GameCategory.allCases.compactMap { $0 != .random ? $0.label : nil }
    
    private let categories = GameCategory.allCases.filter { $0 != .random }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        GameCenterHelper.shared.viewController = self
        // Add an observer to monitor Game Center auth status.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(authenticationChanged(_:)),
            name: .authenticationChanged,
            object: nil
        )
        
        setup(radarChartView: chartView)
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
        
        ProgressHUD.show(interaction: false)
        guard let userID = Profiles.userID else { return }
        FirebaseHelper.getGameHistory(userID: userID) { [weak self] histories, error in
            ProgressHUD.dismiss()
            guard let self = self else { return }
            if let histories = histories {
                // Add all remote histories to the set.
                Profiles.playedGameIDs = Set(histories.map { $0.gameID })
                let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double.random(in: 0..<80) + 20) }
                let entries2 = (0..<self.categoryLabels.count).map(block)
                self.setChartData(entries1: self.historiesToEntries(histories: histories), entries2: entries2)
            } else if let error = error {
                self.presentAlert(error: error)
            }
        }
    }
    
    private func historiesToEntries(histories: [GameHistory]) -> [RadarChartDataEntry] {
        categories.map { category in
            let categoryHistories = histories.filter { $0.gameCategory == category }
            let value: Double
            if categoryHistories.isEmpty {
                value = 0
            } else {
                value = categoryHistories.map { $0.score }.reduce(0, +) / Double(categoryHistories.count)
            }
            return RadarChartDataEntry(value: value * 100)
        }
    }
    
    @IBAction func leaderBoardButtonTapped(_ sender: UIButton) {
        GameCenterHelper.shared.presentLeaderBoard()
    }
    
    @IBAction func achievementsButtonTapped(_ sender: UIButton) {
        GameCenterHelper.shared.presentAchievements()
    }
    
    @objc
    private func authenticationChanged(_ notification: Notification) {
        achievementsButton.isEnabled = notification.object as? Bool ?? false
        leaderboardButton.isEnabled = notification.object as? Bool ?? false
        // Dim the buttons when disabled.
        achievementsButton.alpha = achievementsButton.isEnabled ? 1 : 0.6
        leaderboardButton.alpha = leaderboardButton.isEnabled ? 1 : 0.6
    }
}

extension MetricsViewController: ChartViewDelegate {
    func setup(radarChartView chartView: RadarChartView) {
        chartView.delegate = self
        chartView.backgroundColor = .secondarySystemBackground
        chartView.layer.cornerRadius = 20
        
        chartView.chartDescription.enabled = false
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.webColor = .darkGray
        chartView.innerWebColor = .darkGray
        chartView.webAlpha = 1
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = .label
        
        let yAxis = chartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false
        
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .bottom
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.font = .preferredFont(forTextStyle: .headline)
        legend.xEntrySpace = 7
        legend.yEntrySpace = 5
        legend.textColor = .label
    }
    
    func setChartData(entries1: [RadarChartDataEntry], entries2: [RadarChartDataEntry]) {
        let set1 = RadarChartDataSet(entries: entries1, label: "My Scores")
        set1.setColor(UIColor(red: 103 / 255, green: 110 / 255, blue: 129 / 255, alpha: 1))
        set1.fillColor = UIColor(red: 103 / 255, green: 110 / 255, blue: 129 / 255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let set2 = RadarChartDataSet(entries: entries2, label: "Jigsaw Average")
        set2.setColor(UIColor(red: 121 / 255, green: 162 / 255, blue: 175 / 255, alpha: 1))
        set2.fillColor = UIColor(red: 121 / 255, green: 162 / 255, blue: 175 / 255, alpha: 1)
        set2.drawFilledEnabled = true
        set2.fillAlpha = 0.7
        set2.lineWidth = 2
        set2.drawHighlightCircleEnabled = true
        set2.setDrawHighlightIndicators(false)
        
        let data = RadarChartData(dataSets: [set1, set2])
        data.setValueFont(.systemFont(ofSize: 13, weight: .light))
        data.setDrawValues(false)
        data.setValueTextColor(.label)
        
        chartView.data = data
    }
}

//extension MetricsViewController: AxisValueFormatter{
//    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
//        return categoryLabels[Int(value) % categoryLabels.count]
//    }
//}
