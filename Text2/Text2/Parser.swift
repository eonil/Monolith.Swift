//
//  Parser.swift
//  Text2
//
//  Created by Hoon H. on 10/22/14.
//
//

import Foundation

///	Token with user-supplied classification type.
struct Token {
	var	storage:String
	var	range:Range<String.Index>
}

///	Token based parser.
struct Parser<A:Equatable> {
	typealias	Element		=	Token
	typealias	Scanner		=	Text2.Scanner<Element>
	typealias	Cursor		=	Text2.Cursor<Element>
	typealias	Parser		=	Text2.Analyser<Element,A>
	typealias	Status		=	Text2.Status<Element,A>
	typealias	Node		=	Text2.Node<Element,A>
	typealias	Component	=	Text2.Component<Element>
}