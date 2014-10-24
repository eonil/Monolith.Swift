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
extension Standard.RFC4627.Value : CollectionType {
	
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

	public subscript(name:Swift.String) -> Value? {
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
	
	
	
	
	
	
	
}
























//
//	Fragment description is missing due to lack of implementation in Cocoa.
//	We need to implement our own generator and parser.
//
/////	MARK:
//extension Standard.RFC4627.Value: Printable {
//	public var description:Swift.String {
//		get {
//			
//			
//			switch self {
//			case let .Object(s):	return	"{}"
//			case let .Array(s):		return	"[]"
//			case let .String(s):	return	"\"\""
//			case let .Number(s):	return	""
//			case let .Boolean(s):	return	""
//			case let .Null:			return	"null"
//			}
//			
////			let	d1	=	Standard.JSON.serialise(self)
////			let	s2	=	NSString(data: d1!, encoding: NSUTF8StringEncoding) as Swift.String
////			return	s2
//		}
//	}
//}




//private func escapeString(s:String) -> String {
//	func shouldEscape(ch1:Character) -> (shouldPrefix:Bool, specifier:Character) {
//		switch ch1 {
//		case "\u{0022}":	return	(true, "\"")
//		case "\u{005C}":	return	(true, "\\")
//		case "\u{002F}":	return	(true, "/")
//		case "\u{0008}":	return	(true, "b")
//		case "\u{000C}":	return	(true, "f")
//		case "\u{000A}":	return	(true, "n")
//		case "\u{000D}":	return	(true, "r")
//		case "\u{0009}":	return	(true, "t")
//		default:			return	(false, ch1)
//		}
//	}
//	typealias	Step	=	() -> Cursor
//	enum Cursor {
//		case None
//		case Available(Character, Step)
//		
//		static func restep(s:String) -> (Character, Step) {
//			let	first	=	s[s.startIndex] as Character
//			let	rest	=	s[s.startIndex.successor()..<s.endIndex]
//			let	step	=	Cursor.restep(rest)
//			return	(first, step)
//		}
//	}
//	
//	return	step1
//}



























