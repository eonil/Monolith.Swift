//
//  RFC4627.Parsing.swift
//  Monolith
//
//  Created by Hoon H. on 10/21/14.
//
//

import Foundation

public extension Standard.RFC4627 {
	
}








private typealias	Step	=	() -> Cursor
private enum Cursor {
	case None
	case Available(Character, Step)
	
	static func restep(s:String) -> (Character, Step) {
		let	first	=	s[s.startIndex] as Character
		let	rest	=	s[s.startIndex.successor()..<s.endIndex]
		let	step	=	Cursor.restep(rest)
		return	(first, step)
	}
}



private class Parser {
}
