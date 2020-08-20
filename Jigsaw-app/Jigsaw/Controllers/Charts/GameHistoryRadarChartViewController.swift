//
//  GameHistoryRadarChartViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Charts

class GameHistoryRadarChartViewController: UIViewController, ChartViewDelegate {
    @IBOutlet var chartView: RadarChartView!
    
    private let categories = GameCategory.allCases.map { $0.rawValue }
    
    private var originalBarBgColor: UIColor!
    private var originalBarTintColor: UIColor!
    private var originalBarStyle: UIBarStyle!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "History comparison"
        
        setup(radarChartView: chartView)
        
        updateChartData()
        
        chartView.animate(xAxisDuration: 1.4, yAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    func setup(radarChartView chartView: RadarChartView) {
        chartView.delegate = self
        
        chartView.chartDescription?.enabled = false
        chartView.webLineWidth = 1
        chartView.innerWebLineWidth = 1
        chartView.webColor = .lightGray
        chartView.innerWebColor = .lightGray
        chartView.webAlpha = 1
        
        let xAxis = chartView.xAxis
        xAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        xAxis.xOffset = 0
        xAxis.yOffset = 0
        xAxis.valueFormatter = self
        xAxis.labelTextColor = .white
        
        let yAxis = chartView.yAxis
        yAxis.labelFont = .systemFont(ofSize: 11, weight: .light)
        yAxis.labelCount = 5
        yAxis.axisMinimum = 0
        yAxis.axisMaximum = 80
        yAxis.drawLabelsEnabled = false
        
        let legend = chartView.legend
        legend.horizontalAlignment = .center
        legend.verticalAlignment = .top
        legend.orientation = .horizontal
        legend.drawInside = false
        legend.font = .systemFont(ofSize: 15, weight: .light)
        legend.xEntrySpace = 7
        legend.yEntrySpace = 5
        legend.textColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.15) {
            let navBar = self.navigationController!.navigationBar
            self.originalBarBgColor = navBar.barTintColor
            self.originalBarTintColor = navBar.tintColor
            self.originalBarStyle = navBar.barStyle
            
            navBar.barTintColor = self.view.backgroundColor
            navBar.tintColor = .lightGray
            navBar.barStyle = .black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIView.animate(withDuration: 0.15) {
            let navBar = self.navigationController!.navigationBar
            navBar.barTintColor = self.originalBarBgColor
            navBar.tintColor = self.originalBarTintColor
            navBar.barStyle = self.originalBarStyle
        }
    }
    
    func updateChartData() {
        setChartData()
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
        data.setValueTextColor(.lightText)
        
        chartView.data = data
    }
}

extension GameHistoryRadarChartViewController: IAxisValueFormatter {
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return categories[Int(value) % categories.count]
    }
}
