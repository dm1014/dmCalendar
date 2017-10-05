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

public extension dmCalendarDate {
	static func == (lhs: dmCalendarDate, rhs: dmCalendarDate) -> Bool {
		return lhs.day == rhs.day && lhs.month == rhs.month && lhs.year == rhs.year
	}
}
