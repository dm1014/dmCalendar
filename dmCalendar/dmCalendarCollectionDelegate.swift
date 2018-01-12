//
//  dmCalendarCollectionDelegate.swift
//  dmCalendarExample
//
//  Created by David Martin on 6/1/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol dmCalendarCollectionDelegate: class {
	@objc optional func calendar(_ calendar: dmCalendar, shouldSelectItemAt indexPath: IndexPath) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, shouldDeselectItemAt indexPath: IndexPath) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, shouldHighlightItemAt indexPath: IndexPath) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, didSelectItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, didDeselectItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, didHighlightItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, didUnhighlightItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath)
	@objc optional func calendar(_ calendar: dmCalendar, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
	@objc optional func calendar(_ calendar: dmCalendar, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
	@objc optional func calendar(_ calendar: dmCalendar, canFocusItemAt indexPath: IndexPath) -> Bool
	@objc optional func calendar(_ calendar: dmCalendar, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
	@objc optional func indexPathForPreferredFocusedView(in calendar: dmCalendar) -> IndexPath?
}
