//
//  dmCalendarProperties.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/29/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

enum dmCalendarItemSize {
	case sizeToFit
	case custom(CGFloat)
}

public struct dmCalendarProperties {
	let calendarSize: CGSize
	let itemSize: dmCalendarItemSize
	let headerReferenceSize: CGSize
	let scrollDirection: UICollectionViewScrollDirection
	let minimumLineSpacing: CGFloat
	let minimumInteritemSpacing: CGFloat
	let isPagingEnabled: Bool
	let allowSelection: Bool
	let allowMultipleSelection: Bool
	
	init(calendarSize: CGSize, itemSize: dmCalendarItemSize, headerReferenceSize: CGSize, scrollDirection: UICollectionViewScrollDirection, minimumLineSpacing: CGFloat, minimumInteritemSpacing: CGFloat, isPagingEnabled: Bool, allowSelection: Bool, allowMultipleSelection: Bool) {
		self.calendarSize = calendarSize
		self.itemSize = itemSize
		self.headerReferenceSize = headerReferenceSize
		self.scrollDirection = scrollDirection
		self.minimumLineSpacing = minimumLineSpacing
		self.minimumInteritemSpacing = minimumInteritemSpacing
		self.isPagingEnabled = scrollDirection == .horizontal || isPagingEnabled == true
		self.allowSelection = allowSelection
		self.allowMultipleSelection = allowMultipleSelection
	}
}
