//
//  ExampleHeader.swift
//  dmCalendarExample
//
//  Created by David Martin on 1/11/18.
//  Copyright © 2018 dm Apps. All rights reserved.
//

import Foundation
import UIKit

class ExampleHeader: UICollectionReusableView {
	fileprivate enum Constants {
		enum Formatters {
			static let date: DateFormatter = {
				let formatter = DateFormatter()
				formatter.dateFormat = "MMM yyyy"
				return formatter
			}()
		}
	}
	
	fileprivate let monthLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20.0, weight: .semibold)
		label.textColor = .black
		return label
	}()
	
	open var date: Date? {
		didSet {
			guard let date = date else { return }
			monthLabel.text = Constants.Formatters.date.string(from: date)
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .white
		
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupViews() {
		addSubview(monthLabel)
		
		let monthTop = monthLabel.topAnchor.constraint(equalTo: topAnchor)
		let monthLeft = monthLabel.leftAnchor.constraint(equalTo: leftAnchor)
		let monthRight = monthLabel.rightAnchor.constraint(equalTo: rightAnchor)
		let monthBottom = monthLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
		
		NSLayoutConstraint.activate([monthTop, monthLeft, monthRight, monthBottom])
	}
	
	override func prepareForReuse() {
		monthLabel.text = nil
		date = nil
		
		super.prepareForReuse()
	}
}
