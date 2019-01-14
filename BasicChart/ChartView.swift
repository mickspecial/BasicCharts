//
//  ChartView.swift
//  BasicChart
//
//  Created by Michael Schembri on 14/1/19.
//  Copyright © 2019 Michael Schembri. All rights reserved.
//

import UIKit
import Charts

class ChartView: UIView {
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setupView()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setupView()
	}
	
	var	chartView: LineChartView = {
		let view = LineChartView()
		return view
	}()
	
	func setupView() {
		backgroundColor = .darkGray
		addSubview(chartView)
		chartView.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			chartView.leadingAnchor.constraint(equalTo: leadingAnchor),
			chartView.trailingAnchor.constraint(equalTo: trailingAnchor),
			chartView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 40),
			chartView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
			])
	}
}
