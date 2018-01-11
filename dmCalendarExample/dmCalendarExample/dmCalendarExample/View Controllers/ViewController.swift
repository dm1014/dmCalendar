//
//  ViewController.swift
//  dmCalendarExample
//
//  Created by David Martin on 1/10/18.
//  Copyright © 2018 dm Apps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	fileprivate let calendarView: dmCalendar = {
		let properties = dmCalendarProperties()
		properties.itemSize = .sizeToFit
		properties.headerReferenceSizeHeight = 50.0
		
		let view = dmCalendar(focusingOn: Date(), properties: properties)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = .red
		return view
	}()

	init() {
		super.init(nibName: nil, bundle: nil)
		
		view.backgroundColor = .white
		
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	fileprivate func setupViews() {
		view.addSubview(calendarView)
		
		calendarView.delegate = self
		calendarView.dataSource = self
		
		calendarView.register(ExampleCell.self, forCellWithReuseIdentifier: "ExampleCell")
		calendarView.register(ExampleHeader.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ExampleHeader")
		
		let calendarTop = calendarView.topAnchor.constraint(equalTo: view.topAnchor)
		let calendarLeft = calendarView.leftAnchor.constraint(equalTo: view.leftAnchor)
		let calendarRight = calendarView.rightAnchor.constraint(equalTo: view.rightAnchor)
		let calendarBottom = calendarView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		
		NSLayoutConstraint.activate([calendarTop, calendarLeft, calendarRight, calendarBottom])
	}
	
}

extension ViewController: dmCalendarCollectionDelegate, dmCalendarCollectionDataSource {
	func calendar(_ calendar: dmCalendar, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = calendar.dequeueReusableCell(withReuseIdentifier: "ExampleCell", for: indexPath) as? ExampleCell, let date = calendar.dateForIndexPath(indexPath) else { return UICollectionViewCell() }
		
		cell.date = calendar.calendarDateFromDate(date)
		cell.isInMonth = calendar.isCellInMonth(at: indexPath)
		
		return cell
	}
	
	func calendar(_ calendar: dmCalendar, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let view = calendar.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ExampleHeader", for: indexPath) as? ExampleHeader else { return UICollectionReusableView() }
		
		view.date = calendar.firstDayInSection(indexPath.section)
		
		return view
	}
}
