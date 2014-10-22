//
//  Test.swift
//  Text2
//
//  Created by Hoon H. on 10/22/14.
//
//

import Foundation

struct Test {
	static func run() {
		func assert(b1:@autoclosure()->Bool) {
			Swift.assert(b1)
			if !b1() {
				fatalError("Test assertion failed.")
			}
		}
		func tx(f1:()->()) {
			f1()
		}
		func session(name:String, f1:()->()) {
			println("Test session: " + name)
			f1()
		}
		
		
		
		
		
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	letter	=	one("A")
			let	program	=	t(letter)
			
			////
			
			let	s1	=	"A"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 1)
			assert(x1.data.subnodes.count == 0)
			let	y1	=	x1.data.components[0]
			println(y1)
			
			assert(y1.value! == "A")
		}
		
		session("Iteration") {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	letter	=	one("A")
			let	letter2	=	t(letter)
			let	program	=	lex.Analyser.iteration(atoms: GeneratorOf<lex.Analyser.Rule>([letter2, letter2, letter2].generate()), minimumOccurrence: nil, maximumOccurrence: nil)
			
			////
			
			let	s1	=	"AAA"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 3)
			assert(x1.data.subnodes.count == 0)
			let	y1	=	 { x1.data.components[$0] }
			println(y1(0))
			println(y1(1))
			println(y1(2))
			
			assert(y1(0).value! == "A")
			assert(y1(1).value! == "A")
			assert(y1(2).value! == "A")
		}
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	letter	=	one("A")
			let	letter2	=	t(letter)
			let	program	=	lex.Analyser.repetition(letter2, min: nil, max: nil)
			
			////
			
			let	s1	=	"AAA"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 3)
			assert(x1.data.subnodes.count == 0)
			let	y1	=	 { x1.data.components[$0] }
			println(y1(0))
			println(y1(1))
			println(y1(2))
			
			assert(y1(0).value! == "A")
			assert(y1(1).value! == "A")
			assert(y1(2).value! == "A")
		}
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	letters	=	t(any(["A", "B", "C"]))
			let	program	=	lex.Analyser.repetition(letters, min: nil, max: nil)
			
			////
			
			let	s1	=	"ABC"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 3)
			assert(x1.data.subnodes.count == 0)
			let	y1	=	 { x1.data.components[$0] }
			println(y1(0))
			println(y1(1))
			println(y1(2))
			
			assert(y1(0).value! == "A")
			assert(y1(1).value! == "B")
			assert(y1(2).value! == "C")
		}
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	letters	=	t(any(["A", "B", "C"]))
			let	program	=	lex.Analyser.repetition(letters, min: nil, max: nil)
			
			////
			
			let	s1	=	"AAABBBCCC"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 9)
			assert(x1.data.subnodes.count == 0)
			let	y1	=	 { x1.data.components[$0] }
			println(y1(0))
			println(y1(1))
			println(y1(2))
			println(y1(3))
			println(y1(4))
			println(y1(5))
			println(y1(6))
			println(y1(7))
			println(y1(8))
			
			assert(y1(0).value! == "A")
			assert(y1(1).value! == "A")
			assert(y1(2).value! == "A")
			assert(y1(3).value! == "B")
			assert(y1(4).value! == "B")
			assert(y1(5).value! == "B")
			assert(y1(6).value! == "C")
			assert(y1(7).value! == "C")
			assert(y1(8).value! == "C")
		}
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	ch1		=	t(one("B"))
			let ch2		=	t(any(["A", "C"]))
			let	ch3		=	lex.Analyser.choice([ch1, ch2])
			let	program	=	ch3
			
			////
			
			let	s1	=	"CCC"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.annotation)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			assert(x1.data.components.count == 1)
			assert(x1.data.components[0].value == "C")
		}
		
		tx {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	MARK	=	"Here be dragons."
			
			let	t		=	lex.Analyser.test
			let	ch1		=	t(one("B"))
			let	ch2		=	lex.Analyser.trigger(rule: ch1, filter: { println(MARK); return ($0, $1) })
			let	program	=	ch2
			
			////
			
			let	s1	=	"B"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.annotation)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			assert(x1.data.components.count == 1)
			assert(x1.data.components[0].value == "B")
		}
		
		session("Annotation") {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	MARK	=	"Here be dragons."
			
			let	t		=	lex.Analyser.test
			let	ch1		=	t(one("A"))
			let	ch2		=	lex.Analyser.annotation(rule: ch1, annotation: MARK)
			let	program	=	ch2
			
			////
			
			let	s1	=	"A"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.annotation)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			assert(x1.data.annotation == MARK)
			assert(x1.data.components.count == 1)
			assert(x1.data.components[0].value == "A")
			assert(x1.data.subnodes.count == 0)
		}
		
		session("Choice") {
			typealias	lex	=	Lexer<String>
			
			let	one		=	lex.one
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	ch1		=	t(one("B"))
			let ch2		=	t(any(["A", "C"]))
			let	ch3		=	lex.Analyser.choice([ch1, ch2])
			let	ch4		=	lex.Analyser.repetition(ch3)
			let	program	=	ch4
			
			////
			
			let	s1	=	"CCC"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.annotation)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			assert(x1.data.components.count == 3)
			assert(x1.data.components[0].value == "C")
			assert(x1.data.components[1].value == "C")
			assert(x1.data.components[2].value == "C")
		}
		
		
		session("Repetition") {
			enum Kind {
				case Symbol
				case Punctuation
			}
			
			typealias	lex	=	Lexer<Kind>
			
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			////
			
			let	t		=	lex.Analyser.test
			let	punc	=	any(["(", ")"])
			let	letter	=	any(["a", "b", "c"])
			let	char1	=	or([punc,letter])
			let	char2	=	t(char1)
			let	program	=	lex.Analyser.repetition(char2)
			
			////
			
			let	s1	=	"(abc)"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			assert(x1.done)
			println(x1)
			println(x1.data.components.count)
			println(x1.data.subnodes.count)
			
			assert(x1.data.components.count == 5)
			let ch1	=	{ (index:Int) -> Character in
				assert(x1.data.components[index].value != nil)
				let	ch1	=	x1.data.components[index].value!
				println(ch1)
				return	ch1
			}
			assert(ch1(0) == "(")
			assert(ch1(1) == "a")
			assert(ch1(2) == "b")
			assert(ch1(3) == "c")
			assert(ch1(4) == ")")
			assert(x1.data.components.count == 5)
		}
		
		session("Sequence+Choice") {
			enum Kind {
				case Symbol
				case Punctuation
			}
			
			typealias	lex	=	Lexer<Kind>
			
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			func cls(rule:lex.Analyser.Rule, annotation:Kind) -> lex.Analyser.Rule {
				return	lex.Analyser.annotation(rule: rule, annotation: annotation)
			}
			
			////
			
			let	punc1	=	any(["(", ")"])
			let	letter1	=	any(["a", "b", "c"])
			
			let	t		=	lex.Analyser.test
			let	punc2	=	t(punc1)
			let	letter2	=	t(letter1)
			let	punc3	=	cls(punc2, Kind.Punctuation)
			let	letter3	=	cls(letter2, Kind.Symbol)
			
			let	char	=	lex.Analyser.choice([punc3,letter3])
			let	chars	=	lex.Analyser.sequence([char, char, char])
			let	program	=	chars
			
			////
			
			let	s1	=	"(abc)"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			println(x1)
			assert(x1.data.components.count == 3)
			let	y1	=	{ x1.data.components[$0] }
			assert(y1(0).value == "(")
			assert(y1(1).value == "a")
			assert(y1(2).value == "b")
			let	z1	=	{ x1.data.subnodes[$0] }
			assert(z1(0).annotation == Kind.Punctuation)
			assert(z1(1).annotation == Kind.Symbol)
			assert(z1(2).annotation == Kind.Symbol)
		}
		
		
		
		session("Limited repetition") {
			enum Kind {
				case Symbol
				case Punctuation
			}
			
			typealias	lex	=	Lexer<Kind>
			
			let	any		=	lex.any
			let	or		=	lex.Scanner.or
			let	not		=	lex.Scanner.not
			
			func cls(rule:lex.Analyser.Rule, annotation:Kind) -> lex.Analyser.Rule {
				return	lex.Analyser.annotation(rule: rule, annotation: annotation)
			}
			
			////
			
			let	punc1	=	any(["(", ")"])
			let	letter1	=	any(["a", "b", "c"])
			
			let	t		=	lex.Analyser.test
			let	punc2	=	t(punc1)
			let	letter2	=	t(letter1)
			let	punc3	=	cls(punc2, Kind.Punctuation)
			let	letter3	=	cls(letter2, Kind.Symbol)
			
			let	char	=	lex.Analyser.choice([punc3,letter3])
			let	chars	=	lex.Analyser.repetition(char, min: 3, max: 3)
			let	program	=	chars
			
			////
			
			let	s1	=	"(abc)"
			let	c1	=	lex.Cursor(GeneratorOf<Character>(s1.generate()))
			let	x1	=	program(cursor: c1)
			
			println(x1)
			assert(x1.data.components.count == 3)
			assert(x1.data.subnodes.count == 3)
			let	y1	=	{ x1.data.components[$0] }
			let	z1	=	{ x1.data.subnodes[$0] }
			assert(y1(0).value == "(")
			assert(y1(1).value == "a")
			assert(y1(2).value == "b")
			assert(z1(0).annotation == Kind.Punctuation)
			assert(z1(1).annotation == Kind.Symbol)
			assert(z1(2).annotation == Kind.Symbol)
			
		}
	}
}

















