//
//  dmCalendarDate.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/18/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

public struct dmCalendarDate {
	let day: Int
	let month: Int
	let year: Int
}

// MARK: - dmCalendarDate Components
public extension dmCalendarDate {
	public func dateComponents() -> DateComponents {
		var components = DateComponents()
		components.day = self.day
		components.month = self.month
		components.year = self.year
		
		return components
	}
}

// MARK: - dmCalendarDate Comparisons
public extension dmCalendarDate {
	static func == (lhs: dmCalendarDate, rhs: dmCalendarDate) -> Bool {
		return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
	}
}

// MARK: - DateFormetter Extensions
public extension DateFormatter {
	func string(from date: dmCalendarDate) -> String? {
		let gregorian: Calendar = {
			var calendar = Calendar.current
			calendar.timeZone = .current
			return calendar
		}()
		
		guard let date = gregorian.date(from: date.dateComponents()) else { return nil }
		return self.string(from: date)
	}
	
	func date(from date: dmCalendarDate) -> Date? {
		let gregorian: Calendar = {
			var calendar = Calendar.current
			calendar.timeZone = .current
			return calendar
		}()
		
		return gregorian.date(from: date.dateComponents())
	}
}
