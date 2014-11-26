//
//  Preconditions.swift
//  UIKitExtras
//
//  Created by Hoon H. on 11/26/14.
//
//

import Foundation
import UIKit


public func preconditionNoAutoresizingMasking(v:UIView?) {
	if let v1 = v {
		precondition(v1.translatesAutoresizingMaskIntoConstraints() == false, "You cannot supply a view with autoresizing-mask set to `true` for this.")
	}
}
