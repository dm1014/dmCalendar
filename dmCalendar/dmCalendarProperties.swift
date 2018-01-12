//
//  dmCalendarProperties.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/29/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

public enum dmCalendarItemSizeHeight {
	case equalToWidth
	case custom(CGFloat)
}

public final class dmCalendarProperties {
	public var itemSizeHeight: dmCalendarItemSizeHeight = .equalToWidth
	public var headerReferenceSizeHeight: CGFloat = 0.0
	public var footerReferenceSizeHeight: CGFloat = 0.0
	public var scrollDirection: UICollectionViewScrollDirection = .vertical
	public var minimumLineSpacing: CGFloat = 0.0
	public var minimumInteritemSpacing: CGFloat = 0.0
	public var isPagingEnabled: Bool = false
	public var allowSelection: Bool = true
	public var allowMultipleSelection: Bool = false
	
	public init() { }
}
