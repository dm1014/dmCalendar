//
//  dmCalendar.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/17/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

public protocol dmCalendarPositionDelegate: class {
	func calendar(_ calendar: dmCalendar, didChange: Bool, fromDate: Date, toDate: Date)
}

public final class dmCalendar: UIView, dmCalendarCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	fileprivate enum Constants {
		static let numberOfDaysInWeek = 7
		static let maximumNumberOfRows = 6
		static let firstDayIndex = 0
		static let numberOfDaysIndex = 1
		static let selectedDateIndex = 2
		
		static let day: CGFloat = 60.0 * 60.0 * 24.0
	}
	
	fileprivate lazy var calendarCollection: dmCalendarCollectionView = {
		let layout = dmCalendarCollectionLayout()
		
		let view = dmCalendarCollectionView(frame: .zero, collectionViewLayout: layout)
		view.translatesAutoresizingMaskIntoConstraints = false
		view.delegate = self
		view.dataSource = self
		view.calendarDelegate = self
		view.backgroundColor = .white
		view.showsHorizontalScrollIndicator = false
		view.showsVerticalScrollIndicator = false
		return view
	}()
	
	fileprivate lazy var gregorian: Calendar = {
		var calendar = Calendar.current
		calendar.timeZone = TimeZone.current
		return calendar
	}()
	
	fileprivate let focusedDate: Date
	fileprivate let properties: dmCalendarProperties
	fileprivate var fromDate: dmCalendarDate = dmCalendarDate(day: 0, month: 0, year: 0)
	fileprivate var toDate: dmCalendarDate = dmCalendarDate(day: 0, month: 0, year: 0)
	
	fileprivate var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
	fileprivate var selectedDate: Date = Date()
	
	public weak var delegate: dmCalendarCollectionDelegate?
	public weak var dataSource: dmCalendarCollectionDataSource?
	public weak var calendarPositionDelegate: dmCalendarPositionDelegate?
	
	public var desiredDates: [Date] = []
	public var shouldMonitorScroll = false
	
	public init(focusingOn date: Date, properties: dmCalendarProperties) {
		self.focusedDate = date
		self.properties = properties
		
		super.init(frame: .zero)
		
		setupCalendar()
		setupDates()
		setupViews()
	}
	
	override public func layoutSubviews() {
		super.layoutSubviews()
		calendarCollection.collectionViewLayout.invalidateLayout()
		updateCellSize()
		updateReusableViewSizes()
	}
	
	override public func willMove(toSuperview newSuperview: UIView?) {
		super.willMove(toSuperview: newSuperview)
		
		if newSuperview != nil, let indexPath = indexPathForDate(focusedDate) {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
				self.calendarCollection.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
			})
		}
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupCalendar() {
		let layout = calendarCollection.collectionViewLayout as! dmCalendarCollectionLayout
		layout.scrollDirection = properties.scrollDirection
		layout.minimumLineSpacing = properties.minimumLineSpacing
		layout.minimumInteritemSpacing = properties.minimumInteritemSpacing
		
		calendarCollection.isPagingEnabled = properties.isPagingEnabled
		calendarCollection.allowsSelection = properties.allowSelection
		calendarCollection.allowsMultipleSelection = properties.allowMultipleSelection
	}
	
	fileprivate func setupDates() {
		guard let nowGregorianDate = gregorian.date(from: gregorian.dateComponents([.year, .month], from: focusedDate)) else { fatalError("Can't convert date to gregorian") }
		
		let nowDate = nowGregorianDate
		
		let monthsAgo: DateComponents = {
			var components = DateComponents()
			components.month = -6
			
			return components
		}()
		
		let futureMonths: DateComponents = {
			var components = DateComponents()
			components.month = 6
			
			return components
		}()
		
		guard let fromGregorianDate = gregorian.date(byAdding: monthsAgo, to: nowDate) else { fatalError("Can't convert date to gregorian") }
		
		fromDate = self.calendarDateFromDate(fromGregorianDate)
		
		guard let toGregorianDate = gregorian.date(byAdding: futureMonths, to: nowDate) else { fatalError("Can't convert date to gregorian") }
		
		toDate = self.calendarDateFromDate(toGregorianDate)

		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: {
			guard let futureDate = self.gregorian.date(byAdding: .day, value: 60, to: nowDate) else { return }
			self.calendarPositionDelegate?.calendar(self, didChange: true, fromDate: nowDate, toDate: futureDate)
		})
	}
	
	fileprivate func setupViews() {
		addSubview(calendarCollection)
		
		let calendarTop = calendarCollection.topAnchor.constraint(equalTo: topAnchor)
		let calendarLeft = calendarCollection.leftAnchor.constraint(equalTo: leftAnchor)
		let calendarRight = calendarCollection.rightAnchor.constraint(equalTo: rightAnchor)
		let calendarBottom = calendarCollection.bottomAnchor.constraint(equalTo: bottomAnchor)
		
		NSLayoutConstraint.activate([calendarTop, calendarLeft, calendarRight, calendarBottom])
	}
	
	public final func calendarCollectionViewWillLayoutSubview(_ collection: dmCalendarCollectionView) {
		switch properties.scrollDirection {
		case .horizontal:
			if collection.contentOffset.x < 0.0 {
				addPastDates()
			}
			
			if collection.contentOffset.x > (collection.contentSize.width - collection.bounds.width) {
				addFutureDates()
			}
		case .vertical:
			if collection.contentOffset.y < 0.0 {
				addPastDates()
			}
			
			if collection.contentOffset.y > (collection.contentSize.height - collection.bounds.height) {
				addFutureDates()
			}
		}
	}
	
	fileprivate func updateCellSize() {
		guard let layout = calendarCollection.collectionViewLayout as? dmCalendarCollectionLayout else { return }
		switch properties.itemSizeHeight {
		case .equalToWidth:
			if properties.isPagingEnabled {
				layout.itemSize = CGSize(width: bounds.width / CGFloat(Constants.numberOfDaysInWeek), height: (bounds.height - properties.headerReferenceSizeHeight - properties.footerReferenceSizeHeight) / CGFloat(Constants.maximumNumberOfRows))
			} else {
				layout.itemSize = CGSize(width: bounds.width / CGFloat(Constants.numberOfDaysInWeek), height: bounds.width / CGFloat(Constants.numberOfDaysInWeek))
			}
		case .custom(let height):
			layout.itemSize = CGSize(width: bounds.width / CGFloat(Constants.numberOfDaysInWeek), height: height)
		}
	}
	
	fileprivate func updateReusableViewSizes() {
		guard let layout = calendarCollection.collectionViewLayout as? dmCalendarCollectionLayout else { return }
		layout.headerReferenceSize = CGSize(width: bounds.width, height: properties.headerReferenceSizeHeight)
		layout.footerReferenceSize = CGSize(width: bounds.width, height: properties.footerReferenceSizeHeight)
	}
	
	fileprivate func addPastDates() {
		var components = DateComponents()
		components.month = -6
		moveDates(using: components, addingFutureDates: false)
	}
	
	fileprivate func addFutureDates() {
		var components = DateComponents()
		components.month = 6
		moveDates(using: components, addingFutureDates: true)
	}
	
	fileprivate func moveDates(using components: DateComponents, addingFutureDates: Bool) {
		guard let cvLayout = calendarCollection.collectionViewLayout as? dmCalendarCollectionLayout else { return }
		let cv = self.calendarCollection
		let visibleCells = cv.visibleCells
		
		guard let firstItem = visibleCells.first,
			let fromIndexPath = cv.indexPath(for: firstItem),
			let fromAttributes = cvLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: fromIndexPath.section)),
			let fDate = gregorian.date(byAdding: components, to: dateFromCalendarDate(fromDate)),
			let tDate = gregorian.date(byAdding: components, to: dateFromCalendarDate(toDate)) else { return }
		
		let fromSectionOfDate = firstDayInSection(fromIndexPath.section)
		let fromSectionOrigin = self.convert(fromAttributes.frame.origin, to: cv)
		
		fromDate = calendarDateFromDate(fDate)
		toDate = calendarDateFromDate(tDate)
		
		if shouldMonitorScroll, addingFutureDates {
			calendarPositionDelegate?.calendar(self, didChange: true, fromDate: fDate, toDate: tDate)
		}
		
		cv.reloadData()
		cvLayout.invalidateLayout()
		cvLayout.prepare()
		
		guard let toSection = gregorian.dateComponents([.month], from: firstDayInSection(0), to: fromSectionOfDate).month,
			let toAttributes = cvLayout.layoutAttributesForItem(at: IndexPath(item: 0, section: toSection)) else { return }
		
		let toSectionOrigin = self.convert(toAttributes.frame.origin, to: cv)
		
		switch properties.scrollDirection {
		case .horizontal:
			cv.contentOffset = {
				let offset = cv.contentOffset
				return CGPoint(x: offset.x + (toSectionOrigin.x - fromSectionOrigin.x), y: offset.y)
			}()
		case .vertical:
			cv.contentOffset = {
				let offset = cv.contentOffset
				return CGPoint(x: offset.x, y: offset.y + (toSectionOrigin.y - fromSectionOrigin.y))
			}()
		}
	}
	
	fileprivate func weeksInMonth(for date: Date) -> Int {
		let lastComponents: DateComponents = {
			var components = DateComponents()
			components.month = 1
			components.day = -1
			return components
		}()
		
		guard let firstDayInMonth = gregorian.date(from: gregorian.dateComponents([.year, .month], from: date)),
			let lastDayInMonth = gregorian.date(byAdding: lastComponents, to: firstDayInMonth) else { return 6 }
		
		let fromSundayComponents: DateComponents = {
			var components = gregorian.dateComponents([.weekOfYear, .yearForWeekOfYear], from: firstDayInMonth)
			components.weekday = 1
			return components
		}()
		
		let toSundayComponents: DateComponents = {
			var components = gregorian.dateComponents([.weekOfYear, .yearForWeekOfYear], from: lastDayInMonth)
			components.weekday = 1
			return components
		}()
		
		guard let fromSunday = gregorian.date(from: fromSundayComponents),
			let toSunday = gregorian.date(from: toSundayComponents),
			let weeks = gregorian.dateComponents([.weekOfYear], from: fromSunday, to: toSunday).weekOfYear else { return 6 }
		
		return 1 + weeks
	}
	
	fileprivate func reorderWeekday(_ weekday: Int) -> Int {
		var ordered = weekday - gregorian.firstWeekday
		
		if ordered < 0 {
			ordered = Constants.numberOfDaysInWeek + ordered
		}
		
		return ordered
	}
	
	fileprivate func componentsFromCalendarDate(_ calendarDate: dmCalendarDate) -> DateComponents {
		var components = DateComponents()
		components.day = calendarDate.day
		components.month = calendarDate.month
		components.year = calendarDate.year
		
		return components
	}
	
	fileprivate func sectionForDate(_ date: Date) -> Int? {
		guard let section = gregorian.dateComponents([.month], from: firstDayInSection(0), to: date).month else { return nil }
		return section
	}
	
	fileprivate func headerFrameForSection(_ section: Int) -> CGRect {
		let indexPath = IndexPath(item: 0, section: section)
		guard let attributes = calendarCollection.layoutAttributesForSupplementaryElement(ofKind: UICollectionElementKindSectionHeader, at: indexPath) else { return .zero }
		return attributes.frame
	}
}

// MARK: - Calendar Dates Helpers
extension dmCalendar {
	public final func calendarDateFromDate(_ date: Date) -> dmCalendarDate {
		let components = gregorian.dateComponents([.year, .month, .day], from: date)
		
		guard let day = components.day, let month = components.month, let year = components.year else { fatalError("Gregorian Date Components Error") }
		
		return dmCalendarDate(day: day, month: month, year: year)
	}
	
	public final func dateForIndexPath(_ indexPath: IndexPath) -> Date? {
		let firstDay = firstDayInSection(indexPath.section)
		guard let day = gregorian.dateComponents([.weekday], from: firstDay).weekday else { return nil }
		let weekday = reorderWeekday(day)
		
		let date = gregorian.date(byAdding: {
			var components = DateComponents()
			components.day = indexPath.item - weekday
			return components
		}(), to: firstDay)
		
		return date
	}
	
	public final func dateFromCalendarDate(_ calendarDate: dmCalendarDate) -> Date {
		guard let date = gregorian.date(from: componentsFromCalendarDate(calendarDate)) else { return Date() }
		
		return date
	}
	
	public final func firstDayInSection(_ section: Int) -> Date {
		var components = DateComponents()
		components.month = section
		
		guard let date = gregorian.date(byAdding: components, to: self.dateFromCalendarDate(fromDate)) else { return Date() }
		
		return date
	}
	
	public final func indexPathForDate(_ date: Date) -> IndexPath? {
		guard let monthSection = sectionForDate(date) else { return nil }
		let firstDayInMonth = firstDayInSection(monthSection)
		guard let dayNumber = gregorian.dateComponents([.weekday], from: firstDayInMonth).weekday else { return nil }
		let weekday = reorderWeekday(dayNumber)
		guard let dateItem = gregorian.dateComponents([.day], from: firstDayInMonth, to: date).day else { return nil }
		
		return IndexPath(item: dateItem + weekday, section: monthSection)
	}
	
	public final func indexPathsForDates(_ dates: [Date]) -> [IndexPath] {
		var indexPaths: [IndexPath] = []
		
		for date in dates {
			guard let monthSection = sectionForDate(date) else { return [] }
			let firstDayInMonth = firstDayInSection(monthSection)
			guard let dayNumber = gregorian.dateComponents([.weekday], from: firstDayInMonth).weekday else { return [] }
			let weekday = reorderWeekday(dayNumber)
			guard let dateItem = gregorian.dateComponents([.day], from: firstDayInMonth, to: date).day else { return [] }
			
			let indexPath = IndexPath(item: dateItem + weekday, section: monthSection)
			indexPaths.append(indexPath)
		}
		
		return indexPaths
	}
	
	public final func isDateDesired(using calendarDate: dmCalendarDate) -> Bool {
		let mappedDates = desiredDates.map({ self.calendarDateFromDate($0) })
		return mappedDates.filter({ $0 == calendarDate }).count > 0
	}
	
	public final func isCellInMonth(at indexPath: IndexPath) -> Bool {
		guard let date = dateForIndexPath(indexPath) else { return false }
		let calendarDate = calendarDateFromDate(date)
		let firstDay = firstDayInSection(indexPath.section)
		let firstCalendarDay = calendarDateFromDate(firstDay)
		
		return calendarDate.year == firstCalendarDay.year && calendarDate.month == firstCalendarDay.month
	}
	
	public final func isWithinRange(_ range: Int, from indexPath: IndexPath, to currentIndexPath: IndexPath) -> Bool {
		guard
			let baseDate = dateForIndexPath(indexPath),
			let currentDate = dateForIndexPath(currentIndexPath),
			let baseFuture = gregorian.date(byAdding: .day, value: range - 1, to: baseDate),
			let basePast = gregorian.date(byAdding: .day, value: -range + 1, to: baseDate)
			else { return false }
		
		return currentDate <= baseFuture && currentDate >= basePast
	}
	
	public final func selectIndexPaths(_ indexPaths: [IndexPath]) {
		for indexPath in indexPaths {
			calendarCollection.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
		}
	}
	
	public final func isDateToday(_ calendarDate: dmCalendarDate) -> Bool {
		let date = calendarDateFromDate(Date())
		return date == calendarDate
	}
	
	public final func getDateRange(between firstIndexPath: IndexPath, and secondIndexPath: IndexPath) -> (dates: [Date], indexPaths: [IndexPath]) {
		guard let firstDate = dateForIndexPath(firstIndexPath), let secondDate = dateForIndexPath(secondIndexPath) else { return ([], []) }
		
		var date = firstDate
		var dates: [Date] = [firstDate]
		var paths: [IndexPath] = [firstIndexPath]
		
		while date < secondDate {
			guard let nextDay = gregorian.date(byAdding: .day, value: 1, to: date), let indexPath = indexPathForDate(nextDay) else { continue }
			date = nextDay
			dates.append(nextDay)
			paths.append(indexPath)
		}
		
		return (dates, paths)
	}
	
	public final func isDate(_ date1: Date, inSameDayAs date2: Date) -> Bool {
		return gregorian.isDate(date1, inSameDayAs: date2)
	}
}

// MARK: - Reloading Data
extension dmCalendar {
	public final func reloadItems(at indexPaths: [IndexPath]) {
		calendarCollection.reloadItems(at: indexPaths)
	}
	
	public final func reloadData() {
		calendarCollection.reloadData()
	}
	
	public final func reloadVisibleItems() {
		calendarCollection.reloadItems(at: calendarCollection.indexPathsForVisibleItems)
	}
}

// MARK: - Selecting/Deselecting Items
extension dmCalendar {
	public final func selectItem(at indexPath: IndexPath, animated: Bool, scrollPosition: UICollectionViewScrollPosition) {
		calendarCollection.selectItem(at: indexPath, animated: animated, scrollPosition: scrollPosition)
	}
	
	public final func deselectItem(at indexPath: IndexPath, animated: Bool) {
		calendarCollection.deselectItem(at: indexPath, animated: animated)
	}
}

// MARK: - Registering Cells/Views
extension dmCalendar {
	public func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
		calendarCollection.register(cellClass, forCellWithReuseIdentifier: identifier)
	}
	
	public func register(_ viewClass: AnyClass?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
		calendarCollection.register(viewClass, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
	}
	
	@nonobjc public func register(_ nib: UINib?, forCellWithReuseIdentifier identifier: String) {
		calendarCollection.register(nib, forCellWithReuseIdentifier: identifier)
	}
	
	@nonobjc public func register(_ nib: UINib?, forSupplementaryViewOfKind kind: String, withReuseIdentifier identifier: String) {
		calendarCollection.register(nib, forSupplementaryViewOfKind: kind, withReuseIdentifier: identifier)
	}
	
	@nonobjc public func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionViewCell {
		return calendarCollection.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
	}
	
	@nonobjc public func dequeueReusableSupplementaryView(ofKind elementKind: String, withReuseIdentifier identifier: String, for indexPath: IndexPath) -> UICollectionReusableView {
		return calendarCollection.dequeueReusableSupplementaryView(ofKind: elementKind, withReuseIdentifier: identifier, for: indexPath)
	}
	
	@nonobjc public func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
		return calendarCollection.cellForItem(at: indexPath)
	}
}

// MARK: - dmCalendarCollectionDelegate
extension dmCalendar: UICollectionViewDelegate {
	public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		guard let value = delegate?.calendar?(self, shouldSelectItemAt: indexPath) else { return true }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
		guard let value = delegate?.calendar?(self, shouldDeselectItemAt: indexPath) else { return true }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		guard let value = delegate?.calendar?(self, shouldHighlightItemAt: indexPath) else { return true }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		selectedIndexPath = indexPath
		delegate?.calendar?(self, didSelectItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		delegate?.calendar?(self, didDeselectItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		delegate?.calendar?(self, didHighlightItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		delegate?.calendar?(self, didUnhighlightItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		delegate?.calendar?(self, willDisplay: cell, forItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		delegate?.calendar?(self, didEndDisplaying: cell, forItemAt: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
		delegate?.calendar?(self, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
		delegate?.calendar?(self, didEndDisplayingSupplementaryView: view, forElementOfKind: elementKind, at: indexPath)
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
		guard let value = delegate?.calendar?(self, shouldUpdateFocusIn: context) else { return false }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
		guard let value = delegate?.calendar?(self, canPerformAction: action, forItemAt: indexPath, withSender: sender) else { return false }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
		delegate?.calendar?(self, performAction: action, forItemAt: indexPath, withSender: sender)
	}
	
	public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		delegate?.calendar?(self, didUpdateFocusIn: context, with: coordinator)
	}
	
	public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		guard let value = delegate?.calendar?(self, canFocusItemAt: indexPath) else { return false }
		return value
	}
	
	public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
		guard let value = delegate?.calendar?(self, shouldShowMenuForItemAt: indexPath) else { return false }
		return value
	}
	
	public func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
		return delegate?.indexPathForPreferredFocusedView?(in: self)
	}
}

// MARK: - dmCalendarCollectionDataSource
extension dmCalendar: UICollectionViewDataSource  {
	public func numberOfSections(in collectionView: UICollectionView) -> Int {
		return gregorian.dateComponents([.month], from: dateFromCalendarDate(fromDate), to: dateFromCalendarDate(toDate)).month ?? 0
	}
	
	public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if (properties.scrollDirection == .vertical && properties.isPagingEnabled) || properties.scrollDirection == .horizontal {
			return Constants.numberOfDaysInWeek * Constants.maximumNumberOfRows
		} else {
			return Constants.numberOfDaysInWeek * weeksInMonth(for: firstDayInSection(section))
		}
	}
	
	public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = dataSource?.calendar(self, cellForItemAt: indexPath) else { return UICollectionViewCell() }
		return cell
	}
	
	public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard let view = dataSource?.calendar?(self, viewForSupplementaryElementOfKind: kind, at: indexPath) else { return UICollectionReusableView() }
		return view
	}
	
	public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
		guard let indexPath = dataSource?.calendar?(self, indexPathForIndexTitle: title, at: index) else { return IndexPath(item: 0, section: 0) }
		return indexPath
	}
	
	public func indexTitles(for collectionView: UICollectionView) -> [String]? {
		return dataSource?.indexTitles?(for: self)
	}
}
