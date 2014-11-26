//
//  InternalOnlyExtensions.swift
//  UIKitExtras
//
//  Created by Hoon H. on 11/26/14.
//
//

import Foundation

internal extension Slice {
	var array:Array<Element> {
		get {
			return	Array(self)
		}
	}
}