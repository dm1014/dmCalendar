//
//  ExampleFooter.swift
//  dmCalendarExample
//
//  Created by David Martin on 1/11/18.
//  Copyright © 2018 dm Apps. All rights reserved.
//

import Foundation
import UIKit

class ExampleFooter: UICollectionReusableView {
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		backgroundColor = .groupTableViewBackground
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
