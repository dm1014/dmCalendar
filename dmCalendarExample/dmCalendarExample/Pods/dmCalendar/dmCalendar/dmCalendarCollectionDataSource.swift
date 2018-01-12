//
//  dmCalendarCollectionDataSource.swift
//  dmCalendarExample
//
//  Created by David Martin on 6/1/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol dmCalendarCollectionDataSource: class {
	func calendar(_ calendar: dmCalendar, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
	@objc optional func calendar(_ calendar: dmCalendar, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
	@objc optional func calendar(_ calendar: dmCalendar, indexPathForIndexTitle title: String, at index: Int) -> IndexPath
	@objc optional func indexTitles(for calendar: dmCalendar) -> [String]?
}
