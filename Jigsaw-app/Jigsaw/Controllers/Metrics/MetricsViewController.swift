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

class MetricsViewController: UIViewController {
    @IBOutlet var chartView: RadarChartView!
    
    @IBOutlet var achievementsButton: UIButton! {
        didSet {
            achievementsButton.setImage(UIImage(#imageLiteral(resourceName: "Glyph - Achievements")), for: .normal)
            achievementsButton.imageView?.contentMode = .scaleAspectFit
            achievementsButton.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet var leaderboardButton: UIButton! {
        didSet {
            leaderboardButton.setImage(UIImage(#imageLiteral(resourceName: "Glyph - Leaderboard")), for: .normal)
            leaderboardButton.imageView?.contentMode = .scaleAspectFit
            leaderboardButton.layer.cornerRadius = 8
        }
    }
    
    /// All category labels except Random.
    private let categories = GameCategory.allCases.compactMap { $0 != .random ? $0.label : nil }
    
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
        setChartData()
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
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
    }
}

extension MetricsViewController: ChartViewDelegate {
    func setup(radarChartView chartView: RadarChartView) {
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
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
    
    func setChartData() {
        let min: Double = 20
        let cnt = categories.count
        
        let block: (Int) -> RadarChartDataEntry = { _ in return RadarChartDataEntry(value: Double.random(in: 0..<80) + min) }
        let entries1 = (0..<cnt).map(block)
        let entries2 = (0..<cnt).map(block)
        
        let set1 = RadarChartDataSet(entries: entries1, label: "Jigsaw average")
        set1.setColor(UIColor(red: 103 / 255, green: 110 / 255, blue: 129 / 255, alpha: 1))
        set1.fillColor = UIColor(red: 103 / 255, green: 110 / 255, blue: 129 / 255, alpha: 1)
        set1.drawFilledEnabled = true
        set1.fillAlpha = 0.7
        set1.lineWidth = 2
        set1.drawHighlightCircleEnabled = true
        set1.setDrawHighlightIndicators(false)
        
        let set2 = RadarChartDataSet(entries: entries2, label: "My scores")
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

extension MetricsViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return categories[Int(value) % categories.count]
    }
}
