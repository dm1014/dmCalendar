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
		properties.itemSizeHeight = .equalToWidth // The cell will be equal to it's width
		// Set the heights for the views or else they won't show
		properties.headerReferenceSizeHeight = 50.0
		properties.footerReferenceSizeHeight = 22.0
		
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
		calendarView.register(ExampleFooter.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExampleFooter")
		
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
		
		cell.date = calendar.calendarDateFromDate(date) // Pass in the dmCalendarDate for the indexPath so we can get the day number
		cell.isInMonth = calendar.isCellInMonth(at: indexPath) // If the date is the current month we show it, if not then it's an "empty" cell
		
		return cell
	}
	
	func calendar(_ calendar: dmCalendar, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		switch kind {
		case UICollectionElementKindSectionHeader:
			guard let view = calendar.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "ExampleHeader", for: indexPath) as? ExampleHeader else { return UICollectionReusableView() }

			// We should use the first day in the section.
			// If we use the date at the indexPath it can result in the wrong month being shown
			view.date = calendar.firstDayInSection(indexPath.section)
			
			return view
		case UICollectionElementKindSectionFooter:
			guard let view = calendar.dequeueReusableSupplementaryView(ofKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "ExampleFooter", for: indexPath) as? ExampleFooter else { return UICollectionReusableView() }
			return view
		default:
			return UICollectionReusableView()
		}
	}
}
