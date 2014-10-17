////
////  EDXC.swift
////  EDXC
////
////  Created by Hoon H. on 10/14/14.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//extension Parsing {
//	struct EDXC {
//		struct Syntax {
//		}
//	}
//}
//
//extension Parsing.EDXC.Syntax {
//	typealias	Cursor	=	Parsing.Cursor
//	typealias	Pattern	=	Parsing.Pattern
//	typealias	Rule	=	Parsing.Rule
//	typealias	Engine	=	Parsing.Engine
//
//	struct Rules {
//		struct Characters {
//			static let	whitespace		=	any([" ", "\t", "\n"])
//			static let	listOpener		=	one("(")
//			static let	listCloser		=	one(")")
//			static let	escaper			=	one("\\")
//			static let	escapee			=	any(["\\", "\"", " ", "(", ")"])
////			static let	escapee			=	any(["\\", "\"", " ", "(", ")", "t", "n", "u"])
//			static let	doubleQuote		=	one("\"")
//			static let	nonWhitespace	=	not(whitespace)
//			static let	nonEscaper		=	not(escaper)
//			
//			static let	symbolic		=	not(or([whitespace, escaper, listOpener, listCloser]))
//			static let	quotable		=	not(or([doubleQuote, escaper]))
//			
//			////
//			
//			private typealias	P		=	Pattern
//			private static let	or		=	P.or
//			private static let	not		=	P.not
//			private static let	any		=	P.any
//			private static let	one		=	P.one
//		}
//		
//		static let	whitespaceStrip			=	pat(Characters.whitespace) * (1...Int.max)
//		static let	maybeWhitespaceStrip	=	whitespaceStrip * (0...Int.max)
////		static let	whitespaceExpression	=	sub(whitespaceStrip)
//		
//		static let	escapingSequence		=	lit("\\") + pat(Characters.escapee)
//		static let	symbolicUnit			=	pat(Characters.symbolic) | escapingSequence
//		static let	symbolForm				=	symbolicUnit * (1...Int.max)
//		static let	quotableUnit			=	pat(Characters.quotable) | escapingSequence
//		static let	quotationForm			=	lit("\"") + (quotableUnit * (1...Int.max)) + lit("\"")
//		static let	valueExpression			=	"value-expr"	~~~	symbolForm | quotationForm
//		
//		static let	atomExpression			=	"atom-expr"		~~~	sub(valueExpression) | Lazy.listExpression()
//		
//		static let	atomSeparator			=	whitespaceStrip
//		static let	atomWithSeparator		=	atomSeparator + sub(atomExpression)
//		static let	atomList				=	sub(atomExpression) + atomWithSeparator * (0...Int.max)
//		static let	maybeAtomList			=	atomList * (0...1)
//		static let	listExpression			=	"list-expr"		~~~	mk(lit("(")) + maybeWhitespaceStrip + maybeAtomList + maybeWhitespaceStrip + lit(")")
//		
//		struct Lazy {
//			static func listExpression()(cursor:Cursor) -> Engine.Stepping {
//				return	sub(Rules.listExpression)(cursor: cursor)
//			}
//		}
//		
//		private typealias	C	=	Rule.Component
//		private static let	lit	=	C.literal
//		private static let	pat	=	C.pattern
//		private static let	sub	=	C.subrule
//		private static let	mk	=	C.mark
//		
//		private struct Marks {
//			static let	listStarter	=	Marks.exp("list expression")
//			
//			private static let	exp	=	Marks.exp_
//			private static func	exp_(expectation:String)(composition c1:Rule.Composition)(cursor:Cursor) -> Engine.Stepping {
//				return	C.expect(composition: c1, expectation: expectation)(cursor: cursor)
//			}
//			
//		}
//	}
//}
//
//
