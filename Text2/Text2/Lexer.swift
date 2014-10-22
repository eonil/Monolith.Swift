//
//  Lexer.swift
//  Text2
//
//  Created by Hoon H. on 10/22/14.
//
//

import Foundation



///	Character lexer.
struct Lexer<A:Equatable> {
	typealias	Element		=	Character
	typealias	Scanner		=	Text2.Scanner<Element>
	typealias	Cursor		=	Text2.Cursor<Element>
	typealias	Analyser	=	Text2.Analyser<Element,A>
	typealias	Status		=	Text2.Status<Element,A>
	typealias	Node		=	Text2.Node<Element,A>
	typealias	Component	=	Text2.Component<Element>
	
	init(_ t1:Scanner.Test) {
		_rule	=	Analyser.test(t1)
	}
	
	func run(c1:Cursor) -> Status {
		return	_rule(cursor:c1)
	}
	
	private	let	_rule:Analyser.Rule
}

extension Lexer {
	static func one(ch1:Character)(ch2:Character) -> Bool {
		return	ch1 == ch2
	}
	static func any(chs1:[Character])(ch2:Character) -> Bool {
		for ch1 in chs1 {
			if ch1 == ch2 {
				return	true
			}
		}
		return	false
	}
//	static let or	=	Scanner.or
//	static let not	=	Scanner.not
}