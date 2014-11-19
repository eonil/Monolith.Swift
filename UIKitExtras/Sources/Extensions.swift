//
//  Extensions.swift
//  WeatherTable
//
//  Created by Hoon H. on 11/18/14.
//
//

import Foundation
import UIKit

public extension UIView {
	
	
	///	Gets and sets all layout-constraints at once.
	public var layoutConstraints:[NSLayoutConstraint] {
		get {
			return	self.constraints() as [NSLayoutConstraint]
		}
		set(v) {			
			let	cs1	=	self.constraints()
			self.removeConstraints(cs1)
			assert(self.constraints().count == 0)
			self.addConstraints(v as [AnyObject])
		}
	}
	
	
	
}