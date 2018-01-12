//
//  dmCalendarProperties.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/29/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

enum dmCalendarItemSizeHeight {
	case equalToWidth
	case custom(CGFloat)
}

public class dmCalendarProperties {
	var itemSizeHeight: dmCalendarItemSizeHeight = .equalToWidth
	var headerReferenceSizeHeight: CGFloat = 0.0
	var footerReferenceSizeHeight: CGFloat = 0.0
	var scrollDirection: UICollectionViewScrollDirection = .vertical
	var minimumLineSpacing: CGFloat = 0.0
	var minimumInteritemSpacing: CGFloat = 0.0
	var isPagingEnabled: Bool = false
	var allowSelection: Bool = true
	var allowMultipleSelection: Bool = false
}
