////
////  Scanner.swift
////  Text2
////
////  Created by Hoon H. on 10/21/14.
////
////
//
//import Foundation
//
//
//
/////	`T` is a container type.
//struct Cursor<T:SequenceType> {
//	init(_ data:T) {
//		self.init(data: data, current: data.generate())
//	}
//	
//	var	available:Bool {
//		get {
//			return	_current != nil
//		}
//	}
//	var current:T.Generator.Element {
//		get {
//			return	_current!
//		}
//	}
//	func stepping() -> Cursor<T> {
//		return	Cursor(data: _data, current: _next)
//	}
//	
//	private let	_data:T
//	private let	_current:T.Generator.Element?
//	private let	_next:T.Generator
//	
//	private init(data:T, current:T.Generator) {
//		_data		=	data
//		
//		var	g2		=	current
//		_current	=	g2.next()
//		_next		=	g2
//	}
//}
//
//
//
//
//protocol Scan {
//	func try(Character) -> Bool
//}
//
//struct Scanner {
//	struct any: Scan {
//		let	samples:[Character]
//		func try(ch:Character) -> Bool {
//			for ch2 in samples {
//				if ch == ch2 {
//					return	true
//				}
//			}
//			return	false
//		}
//	}
//	struct or: Scan {
//		let	options:[Scan]
//		func try(ch: Character) -> Bool {
//			for opt1 in options {
//				if opt1.try(ch) {
//					return	true
//				}
//			}
//			return	false
//		}
//	}
//	struct not: Scan {
//		let	one:Scan
//		func try(ch:Character) -> Bool {
//			return	!one.try(ch)
//		}
//	}
//	
//	
////	struct Token {
////		
////		
////		
////		static func sequence(atoms:[Scan]) {
////			
////		}
////
////	}
//}
//
//
//
//struct Lexer {
//	typealias	Classifier	=	String
//	
//	class sequence<T:Equatable>: Tokeniser<T> {
//		let	atoms:[Tokeniser<T>]
//		override init() {
//			
//		}
//		func try(c1: Cursor<String>) -> (status: Tokenisation<Classifier>, continuation: Cursor<String>) {
//			for a1 in atoms {
//				
//			}
//		}
//	}
//	class choice: Tokeniser {
//		let	options:[Tokeniser]
//		func try(c1: Cursor<String>) -> (status: Tokenisation<Classifier>, continuation: Cursor<String>) {
//			
//		}
//	}
//	class repetition: Tokeniser {
//		let	unit:Tokeniser
//		let	occurrence:Occurrence
//		func try(c1: Cursor<String>) -> (status: Tokenisation<Classifier>, continuation: Cursor<String>) {
//			
//		}
//		
//		struct Occurrence {
//			let	min:Int
//			let	max:Int
//		}
//	}
//}
//
//
//
//enum Tokenisation<T:Equatable> {
//	typealias	Classifier	=	T
//	case Done(data:Token<Classifier>)
//	case Error(message:String)
//}
//
//struct Token<T:Equatable> {
//	typealias	Cursor		=	Text2.Cursor<String>
//	typealias	Classifier	=	T
//	let	classification:Classifier
//	let	ranage:(start:Cursor, end:Cursor)
//}
//
//class Tokeniser<T:Equatable> {
//	typealias	Cursor		=	Text2.Cursor<String>
//	typealias	Classifier	=	T
//	func try(Cursor) -> (status:Tokenisation<Classifier>, continuation:Cursor) {
//	}
//}
////protocol TokeniserType {
//////	typealias	Tokeniser	=	Self
////	typealias	Cursor		=	Text2.Cursor<String>
////	typealias	Classifier:		Equatable
////	func try(Cursor) -> (status:Tokenisation<Classifier>, continuation:Cursor)
////	
////}
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
