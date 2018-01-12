//
//  ExampleCell.swift
//  dmCalendarExample
//
//  Created by David Martin on 1/10/18.
//  Copyright © 2018 dm Apps. All rights reserved.
//

import Foundation
import UIKit
import dmCalendar

class ExampleCell: UICollectionViewCell {
	fileprivate let dayLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.textAlignment = .center
		label.textColor = .black
		return label
	}()
	
	open var date: dmCalendarDate? {
		didSet {
			guard let date = date else { return }
			dayLabel.text = "\(date.day)"
		}
	}
	
	open var isInMonth: Bool = true {
		didSet {
			dayLabel.isHidden = !isInMonth
		}
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		contentView.backgroundColor = .white
		
		setupViews()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	fileprivate func setupViews() {
		contentView.addSubview(dayLabel)
		
		let dayTop = dayLabel.topAnchor.constraint(equalTo: contentView.topAnchor)
		let dayLeft = dayLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor)
		let dayRight = dayLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor)
		let dayBottom = dayLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
		
		NSLayoutConstraint.activate([dayTop, dayLeft, dayRight, dayBottom])
	}
	
	override func prepareForReuse() {
		dayLabel.text = nil
		date = nil
		
		super.prepareForReuse()
	}
}
