//
//  ViewController.swift
//  BasicChart
//
//  Created by Michael Schembri on 14/1/19.
//  Copyright © 2019 Michael Schembri. All rights reserved.
//

import UIKit
import Charts

class SessionStatsViewController: UIViewController {
	
	private let chartView = ChartView()
	weak var axisFormatDelegate: IAxisValueFormatter?
	
	override func loadView() {
		view = chartView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		axisFormatDelegate = self
		navigationController?.navigationBar.prefersLargeTitles = true
		title = "Simple Chart"
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		barChartUpdate()
	}
	
	func convertToChartDataEntry(_ dayData: [Date: Double]) -> [ChartDataEntry] {
		let sortedDayData = dayData.sorted { $0.key < $1.key }
		
		var data = [ChartDataEntry]()
		
		sortedDayData.forEach { key, value in
			data.append(ChartDataEntry(x: key.timeIntervalSinceReferenceDate, y: value))
		}
		
		assert(dayData.count == data.count)
		return data
	}
	
	func someFakeData() -> [Date : Double] {
		let date1 = Date()
		let date2 = Calendar.current.date(byAdding: .day, value: -1, to: date1)!
		let date3 = Calendar.current.date(byAdding: .day, value: -2, to: date1)!
		let date4 = Calendar.current.date(byAdding: .day, value: -5, to: date1)!
		let date5 = Calendar.current.date(byAdding: .day, value: -8, to: date1)!

		return [date1: 3, date2: 4, date3: 1, date4: 8, date5: 2]
	}
	
	func barChartUpdate() {

		let chartData = convertToChartDataEntry(someFakeData())
		
		if chartData.isEmpty {
			return
		}
		
		// Set Chart Data
		let dataSet = LineChartDataSet(values: chartData, label: "Things per day")
		let data = LineChartData(dataSets: [dataSet])
		chartView.chartView.data = data
		
		xAxisChartSetUp()
		leftRightAxisChartSetUp()
		styleTheChart(dataSet)
		addChartMarkers()
		setChartScrolling()
		
		chartView.chartView.notifyDataSetChanged()
		chartView.chartView.animate(yAxisDuration: 1.0)
	}
	
	private func leftRightAxisChartSetUp() {
		// Left Axis - main axis
		let leftAxis = chartView.chartView.leftAxis
		leftAxis.valueFormatter = MyLeftAxisFormatter()
		leftAxis.drawGridLinesEnabled = true
		leftAxis.drawZeroLineEnabled = false
		leftAxis.axisMinimum = 0
		leftAxis.labelTextColor = .white
		leftAxis.labelFont = .systemFont(ofSize: 16)
		
		// Right Axis - disabled
		let rightAxis = chartView.chartView.rightAxis
		rightAxis.drawLabelsEnabled = false
		rightAxis.drawGridLinesEnabled = false
		rightAxis.drawAxisLineEnabled = false
	}
	
	private func xAxisChartSetUp() {
		// Set up the xAxis custom format
		let xAxis = chartView.chartView.xAxis
		xAxis.valueFormatter = axisFormatDelegate
		xAxis.avoidFirstLastClippingEnabled = true
		xAxis.drawLimitLinesBehindDataEnabled = true
		xAxis.drawGridLinesEnabled = false
		xAxis.labelPosition = .bottom
		xAxis.labelTextColor = .white
		xAxis.granularity = 1.0
		xAxis.axisLineWidth = 1
		// left right padding of line
		xAxis.spaceMin = 300_000
		xAxis.spaceMax = 300_000
		xAxis.axisLineColor = .white
		xAxis.setLabelCount(5, force: true)
	}
	
	private func styleTheChart(_ dataSet: LineChartDataSet) {
		// Chart Styling
		let orange = UIColor.orange
		dataSet.drawFilledEnabled = false
		dataSet.lineWidth = 2
		dataSet.colors = [orange]
		dataSet.valueColors = [.white]
		dataSet.valueTextColor = .white
		dataSet.axisDependency = .left
		dataSet.drawValuesEnabled = false
		// when clicking marker show crosshairs
		dataSet.drawHorizontalHighlightIndicatorEnabled = false
		dataSet.highlightColor = .white
		// circles
		dataSet.drawCircleHoleEnabled = true
		dataSet.circleRadius = 6
		dataSet.circleColors = [orange]
		dataSet.circleHoleColor = .blue
		dataSet.circleHoleRadius = 4
		// legend
		chartView.chartView.legend.enabled = true
		chartView.chartView.legend.textColor = .white
		chartView.chartView.legend.horizontalAlignment = .left
	}
	
	private func setChartScrolling() {
		chartView.chartView.pinchZoomEnabled = false
		chartView.chartView.scaleYEnabled = false
		chartView.chartView.scaleXEnabled = true
	}
	
	private func addChartMarkers() {
		let marker = PillMarker(color: .white, font: UIFont.boldSystemFont(ofSize: 14), textColor: .black)
		chartView.chartView.marker = marker
	}
	
	var timeConversion: DateComponentsFormatter = {
		let formatter = DateComponentsFormatter()
		formatter.allowedUnits = [.minute, .second]
		formatter.unitsStyle = .positional
		return formatter
	}()
}

class PillMarker: MarkerImage {
	
	private (set) var color: UIColor
	private (set) var font: UIFont
	private (set) var textColor: UIColor
	private var labelText: String = ""
	private var attrs: [NSAttributedString.Key: AnyObject]!
	
	init(color: UIColor, font: UIFont, textColor: UIColor) {
		self.color = color
		self.font = font
		self.textColor = textColor
		
		let paragraphStyle = NSMutableParagraphStyle()
		paragraphStyle.alignment = .center
		attrs = [.font: font, .paragraphStyle: paragraphStyle, .foregroundColor: textColor, .baselineOffset: NSNumber(value: -4)]
		super.init()
	}
	
	override func draw(context: CGContext, point: CGPoint) {
		// custom padding around text
		let labelWidth = labelText.size(withAttributes: attrs).width + 10
		// if you modify labelHeigh you will have to tweak baselineOffset in attrs
		let labelHeight = labelText.size(withAttributes: attrs).height + 4
		
		// place pill above the marker, centered along x
		var rectangle = CGRect(x: point.x, y: point.y, width: labelWidth, height: labelHeight)
		rectangle.origin.x -= rectangle.width / 2.0
		let spacing: CGFloat = 10
		rectangle.origin.y -= rectangle.height + spacing
		
		// rounded rect
		let clipPath = UIBezierPath(roundedRect: rectangle, cornerRadius: 6.0).cgPath
		context.addPath(clipPath)
		context.setFillColor(UIColor.white.cgColor)
		context.setStrokeColor(UIColor.black.cgColor)
		context.closePath()
		context.drawPath(using: .fillStroke)
		
		// add the text
		labelText.draw(with: rectangle, options: .usesLineFragmentOrigin, attributes: attrs, context: nil)
	}
	
	override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
		labelText = customString(entry.y) + "\n" + dateForValue(entry.x)
	}
	
	func dateForValue(_ value: Double) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "d MMM"
		return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value))
	}
	
	private func customString(_ value: Double) -> String {
		let formattedString = "\(Int(value))"
		return "\(formattedString)"
	}
}

extension SessionStatsViewController: IAxisValueFormatter {
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "dd MMM yy"
		return dateFormatter.string(from: Date(timeIntervalSinceReferenceDate: value))
	}
}

class MyLeftAxisFormatter: NSObject, IAxisValueFormatter {
	
	static let formatter: DateComponentsFormatter = {
		let f = DateComponentsFormatter()
		f.allowedUnits = [.minute, .second]
		f.unitsStyle = .positional
		return f
	}()
	
	func stringForValue(_ value: Double, axis: AxisBase?) -> String {
		let formattedString = MyLeftAxisFormatter.formatter.string(from: TimeInterval(value))!
		return "\(formattedString)"
	}
}
