//
//  RFC4627.Extensions.swift
//  Monolith
//
//  Created by Hoon H. on 10/21/14.
//
//

import Foundation


///	`JSON.Value` is treated as an array when you enumerate on it.
///	If underlying value is not an array, it will cause program crash.
///
extension Standard.JSON.Value : CollectionType {
	
	public var startIndex:Int {
		get {
			precondition(array != nil)
			return	array!.startIndex
		}
	}
	public var endIndex:Int {
		get {
			precondition(array != nil)
			return	array!.endIndex
		}
	}

	public subscript(name:Standard.JSON.SwiftString) -> Value? {
		get {
			return	object?[name]
		}
	}
	public subscript(index:Int) -> Value {
		get {
			return	array![index]
		}
	}
	
	public func generate() -> IndexingGenerator<[Value]> {
		precondition(array != nil, "Current `Value` does not contain an array.")
		return	array!.generate()
	}
	
	
	
	
	
	
	
	private typealias	SwiftString	=	Standard.JSON.SwiftString
}