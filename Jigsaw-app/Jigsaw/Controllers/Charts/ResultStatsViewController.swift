//
//  ResultStatsViewController.swift
//  Jigsaw
//
//  Created by Ting Chen on 8/19/20.
//  Copyright © 2020 DukeMobileDevCenter. All rights reserved.
//

import UIKit
import Charts

class ResultStatsViewController: UIViewController {
    @IBOutlet var chartView: PieChartView!
    
    var resultPairs: KeyValuePairs<AnswerCategory, Int>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Game result"
        
        // Setup the half pie chart view.
        setup(pieChartView: chartView)
        updateChartData()
        // Lead in rotating animation.
        chartView.animate(xAxisDuration: 1.4, easingOption: .easeOutBack)
    }
    
    func updateChartData() {
        setDataCount(from: resultPairs)
    }
    
    func setup(pieChartView chartView: PieChartView) {
        chartView.usePercentValuesEnabled = true
        chartView.drawSlicesUnderHoleEnabled = false
        chartView.drawHoleEnabled = true
        chartView.highlightPerTapEnabled = true
        chartView.holeRadiusPercent = 0.58
        chartView.transparentCircleRadiusPercent = 0.61
        chartView.chartDescription?.enabled = false
        chartView.setExtraOffsets(left: 5, top: 10, right: 5, bottom: 5)
        
        chartView.delegate = self
        
        chartView.holeColor = .clear
        chartView.transparentCircleColor = UIColor.systemBackground.withAlphaComponent(0.5)
        chartView.rotationEnabled = false
        
        chartView.maxAngle = 180 // Half chart
        chartView.rotationAngle = 180 // Rotate to make the half on the upper side
        chartView.centerTextOffset = CGPoint(x: 0, y: -25)
        // Center text settings.
        let centerText = NSMutableAttributedString(string: "Results\nby Jigsaw")
        centerText.setAttributes(
            [
                .font: UIFont.systemFont(ofSize: 15),
                .foregroundColor: UIColor.label
            ],
            range: NSRange(location: 0, length: centerText.length)
        )
        centerText.addAttributes(
            [
                .font: UIFont(name: "HelveticaNeue-Light", size: 13)!,
                .foregroundColor: UIColor.systemBlue
            ],
            range: NSRange(location: centerText.length - 6, length: 6)
        )
        
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = .byTruncatingTail
        paragraphStyle.alignment = .center
        
        chartView.drawCenterTextEnabled = true
        chartView.centerAttributedText = centerText
        // Legend settings.
        chartView.legend.horizontalAlignment = .right
        chartView.legend.verticalAlignment = .top
        chartView.legend.orientation = .horizontal
        chartView.legend.drawInside = false
        chartView.legend.xEntrySpace = 7
        chartView.legend.yEntrySpace = 0
        chartView.legend.yOffset = 0
        chartView.legend.font = UIFont.systemFont(ofSize: 15)
    }
    
    func setDataCount(from resultPairs: KeyValuePairs<AnswerCategory, Int>) {
        let totalCount = resultPairs.reduce(0) { $0 + $1.1 }
        let entries = resultPairs.map { (key, value) -> PieChartDataEntry in
            return PieChartDataEntry(
                value: Double(value) / Double(totalCount),
                label: key.rawValue
            )
        }
        
        let set = PieChartDataSet(entries: entries, label: "")
        set.sliceSpace = 3
        set.selectionShift = 10
        set.colors = ChartColorTemplates.material()
        
        let data = PieChartData(dataSet: set)
        
        let percentageFormatter = NumberFormatter()
        percentageFormatter.numberStyle = .percent
        percentageFormatter.maximumFractionDigits = 1
        percentageFormatter.multiplier = 1
        percentageFormatter.percentSymbol = "%"
        data.setValueFormatter(DefaultValueFormatter(formatter: percentageFormatter))
    
        data.setValueFont(UIFont(name: "HelveticaNeue-Light", size: 13)!)
        data.setValueTextColor(.white)
        
        chartView.data = data
        chartView.setNeedsDisplay()
    }
}

extension ResultStatsViewController: ChartViewDelegate {
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        print("chartValueSelected")
    }
    
    func chartValueNothingSelected(_ chartView: ChartViewBase) {
        print("chartValueNothingSelected")
    }
}
