//
//  dmCalendarCollectionLayout.swift
//  dmCalendarExample
//
//  Created by David Martin on 5/30/17.
//  Copyright © 2017 dm1014. All rights reserved.
//

import Foundation
import UIKit

final class dmCalendarCollectionLayout: UICollectionViewLayout {
	fileprivate enum Constants {
		static let numberOfDaysInWeek = 7
		static let numberOfWeeksInMonth = 6
	}
	
	fileprivate var attributeDictionary: [IndexPath: UICollectionViewLayoutAttributes] = [:]
	
	open var scrollDirection: UICollectionViewScrollDirection = .horizontal
	open var itemSize: CGSize = .zero
	open var headerReferenceSize: CGSize = .zero
	open var minimumLineSpacing: CGFloat = 0.0
	open var minimumInteritemSpacing: CGFloat = 0.0
	
	override var collectionViewContentSize: CGSize {
		return getContentSize()
	}
	
	public override init() {
		super.init()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
	
	override func prepare() {
		setupLayout()
	}
	
	fileprivate func setupLayout() {
		attributeDictionary.removeAll()
		
		guard let cv = collectionView, cv.numberOfSections > 0 else { return }
		
		var sectionOffset: CGFloat = 0.0
		
		for section in 0..<cv.numberOfSections {
			guard cv.numberOfItems(inSection: section) > 0 else { continue }
			let items = cv.numberOfItems(inSection: section)
			
			for item in 0..<cv.numberOfItems(inSection: section) {
				let indexPath = IndexPath(item: item, section: section)
				
				if scrollDirection == .horizontal {
					let xPathOffset = CGFloat(section) * cv.bounds.width
					let xPos = xPathOffset + CGFloat(item % Constants.numberOfDaysInWeek) * (cv.bounds.width / CGFloat(Constants.numberOfDaysInWeek) + (minimumInteritemSpacing * 2))
					let yPos = self.headerReferenceSize.height + CGFloat(item / Constants.numberOfDaysInWeek) * (itemSize.height + minimumLineSpacing)
					let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
					attributes.frame = CGRect(x: xPos, y: yPos, width: itemSize.width, height: itemSize.height)
					attributeDictionary[indexPath] = attributes
				} else {
					let xPos = CGFloat(item % Constants.numberOfDaysInWeek) * (cv.bounds.width / CGFloat(Constants.numberOfDaysInWeek) + (minimumInteritemSpacing * 2))
					let yPos = sectionOffset + self.headerReferenceSize.height + (CGFloat(item / Constants.numberOfDaysInWeek) * (itemSize.height + minimumLineSpacing))
					let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
					attributes.frame = CGRect(x: xPos, y: yPos, width: itemSize.width, height: itemSize.height)
					attributeDictionary[indexPath] = attributes
				}
			}
			
			sectionOffset += (headerReferenceSize.height + (CGFloat(items / Constants.numberOfDaysInWeek) * (itemSize.height + minimumLineSpacing)))
		}
	}
	
	override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
		var attributes: [UICollectionViewLayoutAttributes] = []
		
		for attribute in attributeDictionary.values {
			if rect.intersects(attribute.frame) {
				attributes.append(attribute)
			}
		}
		
		return attributes + Array(getSectionHeaderAttributes().values)
	}
	
	override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		return attributeDictionary[indexPath]
	}
	
	override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
		guard elementKind == UICollectionElementKindSectionHeader else { return nil }
		return getSectionHeaderAttributes()[indexPath]
	}
	
	fileprivate func getSectionHeaderAttributes() -> [IndexPath: UICollectionViewLayoutAttributes] {
		guard let cv = collectionView else { return [:] }
		var attributes: [IndexPath: UICollectionViewLayoutAttributes] = [:]
		var sectionOffset: CGFloat = 0.0
		
		for section in 0..<cv.numberOfSections {
			let items = cv.numberOfItems(inSection: section)
			let indexPath = IndexPath(item: 0, section: section)
			let attribute = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: indexPath)
			
			if scrollDirection == .horizontal {
				attribute.frame = CGRect(x: cv.bounds.width * CGFloat(section), y: 0.0, width: headerReferenceSize.width, height: headerReferenceSize.height)
			} else {
				attribute.frame = CGRect(x: 0.0, y: sectionOffset, width: headerReferenceSize.width, height: headerReferenceSize.height)
				sectionOffset += (headerReferenceSize.height + (CGFloat(items / Constants.numberOfDaysInWeek) * (itemSize.height + minimumLineSpacing)))
			}
			
			attribute.zIndex = 999 /// Ensures the header is always on top of the cells
			attributes[indexPath] = attribute
		}
		
		return attributes
	}
	
	fileprivate func getContentSize() -> CGSize {
		guard let cv = collectionView else { return .zero }
		
		if scrollDirection == .horizontal {
			let lastSection = cv.numberOfSections - 1
			let lastItem = cv.numberOfItems(inSection: lastSection) - 1
			guard let lastAttribute = layoutAttributesForItem(at: IndexPath(item: lastItem, section: lastSection)) else { return .zero }
			let contentWidth = lastAttribute.frame.maxX
			return CGSize(width: contentWidth, height: cv.bounds.height)
		} else {
			let lastSection = cv.numberOfSections - 1
			let lastItem = cv.numberOfItems(inSection: lastSection) - 1
			guard let lastAttribute = layoutAttributesForItem(at: IndexPath(item: lastItem, section: lastSection)) else { return .zero }
			let contentHeight = lastAttribute.frame.maxY
			return CGSize(width: cv.bounds.width, height: contentHeight)
		}
	}
	
	override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
		return true
	}
	
	override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
		guard let cv = collectionView else { return UICollectionViewLayoutInvalidationContext() }
		let context = super.invalidationContext(forBoundsChange: newBounds)
		
		if cv.bounds.width == newBounds.width || cv.bounds.height == newBounds.height {
			context.invalidateSupplementaryElements(ofKind: UICollectionElementKindSectionHeader, at: Array(getSectionHeaderAttributes().keys))
		}
		
		return context
	}
}
