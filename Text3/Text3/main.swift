//
//  a.swift
//  Text3
//
//  Created by Hoon H. on 10/22/14.
//
//

import Foundation


///typealias	Element		=	Range<String.Index>

///	An element is an abstracted unit of source data. It can be a character, an index or even a range from 0 to multiple characters.
///	Comparison of Element is fully defined by `RuleTest`. Analyser core does not define equality of element.
typealias	Element		=	Character



final class Rule {
	let	significance:Bool
	let	test:RuleTest

	init(significance:Bool, test:RuleTest) {
		self.significance	=	significance
		self.test			=	test
	}
	var atom:RuleTest.Test? {
		get {
			switch test {
			case let RuleTest.Atom(s):	return	s.test
			default:					return	nil
			}
		}
	}

	var composition:Cursor<Rule>? {
		get {
			switch test {
			case let RuleTest.Composition(s):	return	s.subrules()
			default:							return	nil
			}
		}
	}
}

enum RuleTest {
	typealias	Test	=	(Element)->Bool

	case Atom(test:Test)
	case Composition(mode:Mode, subrules:@autoclosure()->Cursor<Rule>)
	
	var atom:Test? {
		get {
			switch self {
			case let Atom(s):	return	s
			default:			return	nil
			}
		}
	}
	var composition:(mode:Mode, subrules:@autoclosure()->Cursor<Rule>)? {
		get {
			switch self {
			case let Composition(s):	return	s
			default:					return	nil
			}
		}
	}
}





struct Node {
	var	sigificance:Bool
//	var	range:(start:Element, end:Element)
	var	element:Element			///<	Wrongly designed. A location of input element when the node was fully detected. We also need start location anyway.
	var	subnodes:[Node]
	var	error:String?
}








enum Mode {
	case All
	case Any
}

///	Analysation core.
final class Step {
	let	mode:Mode
	let	elements:Cursor<Element>
	let	rules:Cursor<Rule>
	let	nodes:[Node]
	let	substep:Step?
	
	init(mode:Mode, elements:Cursor<Element>, rules:Cursor<Rule>, nodes:[Node], substep:Step?) {
		self.mode		=	mode
		self.elements	=	elements
		self.rules		=	rules
		self.nodes		=	nodes
		self.substep	=	substep
	}

	var error:Bool {	///<	early data exaustion.
		get {
			return	elements.available == false
		}
	}
	var done:Bool {
		get {
			return	rules.available == false
		}
	}
	
	func continuation() -> Step {
		return	stepping()
	}
	
	private func stepping() -> Step {
		precondition(elements.available)
		precondition(rules.available)
		
		if let ss2 = substep {
			if ss2.done == false {
				///	Step sublayer. Keep cursors as is at current layer.
				return	Step(mode: mode, elements: elements, rules: rules, nodes: nodes, substep: ss2.continuation())
			} else {
				///	Remove sublayer.
				///	Bring production of sublayer into current layer if appropriate.
				/// Advance cursors.
				let	ns2	=	ss2.nodes.filter { $0.sigificance }
				let	n2	=	Node(sigificance: rules.current.significance, element: elements.current, subnodes: ns2, error: nil)
				return	Step(mode: mode, elements: elements.continuation(), rules: rules.continuation(), nodes: [n2], substep: nil as Step?)
			}
		}
		
		assert(substep == nil)
		
		switch rules.current.test {
		case let RuleTest.Atom(s):
			switch mode {
			case Mode.All:
				///	Should match all rules at current layer.
				let	ok1	=	s.test(elements.current)
				if ok1 == false {
					///	Current layer failed. Cancel current level immediately with no further advancing.
					return	Step(mode: mode, elements: elements, rules: Cursor.None, nodes: nodes, substep: substep)
				}
				assert(ok1 == true)
				let	n1	=	Node(sigificance: rules.current.significance, element: elements.current, subnodes: [], error: nil)
				let	ns2	=	nodes + [n1]
				return	Step(mode: mode, elements: elements.continuation(), rules: rules.continuation(), nodes: ns2, substep: substep)
				
			case Mode.Any:
				///	Should exit if any rule matched.
				let	ok1	=	s.test(elements.current)
				if ok1 == true {
					///	Finish current level immediately with next element.
					let	n1	=	Node(sigificance: rules.current.significance, element: elements.current, subnodes: [], error: nil)
					let	ns2	=	nodes + [n1]
					return	Step(mode: mode, elements: elements.continuation(), rules: Cursor.None, nodes: ns2, substep: substep)
				} else {
					///	Switch to next rule at same element. Dump any discovered node.
					return	Step(mode: mode, elements: elements, rules: rules.continuation(), nodes: [], substep: substep)
				}
			}
			
		case let RuleTest.Composition(s):
			///	Get into the sublayer...
			let	sr1	=	s.subrules()
			if sr1.available {
				return	Step(mode: s.mode, elements: elements, rules: rules, nodes: [], substep: sr1.current.step(elements))
			} else {
				///	Empty subrule... Just skips current rule.
				return	Step(mode: mode, elements: elements, rules: rules.continuation(), nodes: nodes, substep: substep)
			}
		}
	}
}









//protocol CursorType {
//	typealias	Element
//	
//	var current:Element? { get }
//	var continuation:(@autoclosure() -> Self) { get }
//}
//
//struct Cursor<T>: CursorType {
//	typealias	Element	=	T
//
//	init<C:CursorType>(_ cursor:C) {
//		_cursor	=	cursor
//	}
//	var current:T? {
//		get {
//			return	_cursor.current
//		}
//	}
//	var continuation:(@autoclosure() -> Cursor<T>) {
//		get {
//			return	Cursor<T>(_cursor.continuation())
//		}
//	}
//
//	private let _state:(current:Element?, continuation:@autoclosure()->CursorType)
//}


//protocol CursorType {
//	typealias	Element
//	
//	var available:Bool { get }
//	var current:Element { get }
//	func continuation() -> Self
//}
//
//struct CursorWith<T:CursorType>: CursorType {
//	var available:Bool {
//		get {
//			return	_c.available
//		}
//	}
//	var current:T.Element {
//		get {
//			return	_c.current
//		}
//	}
//	func continuation() -> CursorWith<T> {
//		return	CursorWith<T>(_c: _c.continuation())
//	}
//	
//	private let	_c:T
//}

///	Unlike a *generator* which points post-element index,
///	Cursor points pre-element index. So you can preview one
///	element ahead.
enum Cursor<T> {
	case None
	case Available(current:T,continuation:()->Cursor)
	
	init(_ g1:GeneratorOf<T>) {
		var	g2	=	g1
		let	c1	=	g2.next()
		if let c2 = c1 {
			func continuate() -> Cursor {
				return	Cursor(g2)
			}
			self	=	Cursor.Available(current: c2, continuation: continuate)
		} else {
			self	=	Cursor.None
		}
	}
	
	var available:Bool {
		get {
			switch self {
			case None:	return	false
			default:	return	true
			}
		}
	}
	var current:T {
		get {
			switch self {
			case let .Available(s):	return	s.current
			default:				fatalError("Cannot get current from `None` cursor.")
			}
		}
	}
	func continuation() -> Cursor {
		switch self {
		case let .Available(s):	return	s.continuation()
		default:				fatalError("Cannot continue from `None` cursor.")
		}
	}
}

func cursor<T:SequenceType>(s1:T) -> Cursor<T.Generator.Element> {
	return	cursor(s1.generate())
}
func cursor<T:GeneratorType>(g1:T) -> Cursor<T.Element> {
	return	cursor(GeneratorOf<T.Element>(g1))
}
func cursor<T>(g1:GeneratorOf<T>) -> Cursor<T> {
	return	Cursor<T>(g1)
}
func cursor<T>(a1:[T]) -> Cursor<T> {
	return	Cursor<T>(GeneratorOf<T>(a1.generate()))
}
//func cursor<T>(v1:T?) -> Cursor<T> {
//	return	Cursor<T>(GeneratorOf<T>(GeneratorOfOne<T>(v1)))
//}













extension Rule {
	func step(elements:Cursor<Element>) -> Step {
		let	rules	=	cursor([self])
		return	Step(mode: Mode.All, elements: elements, rules: rules, nodes: [], substep: nil as Step?)
	}
}

//extension Step {
//	var	allStackingLayers:GeneratorOf<Step> {
//		get {
//			
//		}
//	}
//	var currentElementsOverAllLayers:[Element] {
//		get {
//			
//		}
//	}
//}

//struct StepStack: SequenceType {
//	typealias	Element		=	Step
//	typealias	Generator	=	GeneratorOf<Step>
//	let	origin:Step
//	
//	func generate() -> Generator {
//		var	s1	=	origin as Step?
//		func next() -> Step? {
//			let	s2	=	s1
//			s1	=	s1?.substep
//			return	s2
//		}
//		return	GeneratorOf<Step>(next)
//	}
//	
//	func currentElements() -> [Element] {
//		return	lazy(self).map()
//	}
//}



//func step(nodes:[Node], element:Cursor<Element>, rule:Cursor<Rule>) -> (nodes:[Node], continuation:(element:Cursor<Element>, rule:Cursor<Rule>)) {
//	
//}
//
//func step(element:Element, rule:Rule) -> (production:Node?, continuation:(element:Element?, rule:Rule?)) {
//	
//}



///	I don't know why this operator is needed for `[Element?]` type... Compiler doesn't work.
func == <T:Equatable> (a:[T?], b:[T?]) -> Bool {
	if a.count != b.count { return false }
	for i in 0..<a.count {
		if a[i] != b[i] { return false }
	}
	return true
}

func test() {
	struct TestHelper {
		static func currentElementsOfAllLayersOf(s1:Step) -> [Element?] {
			switch s1.substep {
			case let .None:			return	s1.elements.available ? [s1.elements.current] : [nil]
			case let .Some(ss):		return	[s1.elements.current] + currentElementsOfAllLayersOf(ss)
			}
		}
	}
//	func assert(b1:@autoclosure()->Bool) {
//		println(b1())
//		Swift.assert(b1(), "Test assertion failure!")
////		if !b1() {
////			fatalError("Test assertion failure!")
////		}
//	}
	func tx(f1:()->()) {
		f1()
	}
	func test(name:String, f1:()->()) {
		println("Test session: " + name)
		f1()
	}
	
	////
	
	
	
	
	test("Single rule match.") {
		tx {
			let	g1	=	"A"
			
			let	t1	=	{ $0 == "A" as Character }
			let	r1	=	Rule(significance: false, test: RuleTest.Atom(test: t1))
			
			let	es1	=	cursor("A")
			let	rs1	=	cursor([r1])
			let	s1	=	Step(mode: Mode.All, elements: es1, rules: rs1, nodes: [], substep: nil as Step?)
			let	s2	=	s1.continuation()
			
			assert(s1.done == false)
			assert(s2.done)
			assert(s1.nodes.count == 0)
			assert(s2.nodes.count == 1)
			assert(s2.nodes[0].element == "A")
			assert(s2.nodes[0].subnodes.count == 0)
		}
		test("Multiple rule sequence match.") {
			let	g1	=	"ABC".generate()
			
			let	t1	=	{ ($0 == "A" as Character) || ($0 == "B" as Character) || ($0 == "C" as Character) }
			let	r1	=	Rule(significance: false, test: RuleTest.Atom(test: t1))
			
			let	es1	=	cursor(GeneratorOf<Element>(g1))
			let	rs1	=	cursor([r1, r1, r1])
			
			let	s0	=	Step(mode: Mode.All, elements: es1, rules: rs1, nodes: [], substep: nil as Step?)
			assert(s0.done == false)
			assert(s0.nodes.count == 0)
			
			let	s1	=	s0.continuation()
			assert(s1.done == false)
			assert(s1.nodes.count == 1)
			assert(s1.nodes[0].element == "A")
			assert(s1.elements.current == "B")
			
			let	s2	=	s1.continuation()
			assert(s2.done == false)
			assert(s2.nodes.count == 2)
			assert(s2.nodes[0].element == "A")
			assert(s2.nodes[1].element == "B")
			assert(s2.elements.current == "C")
			
			let	s3	=	s2.continuation()
			assert(s3.done == true)
			assert(s3.nodes.count == 3)
			assert(s3.nodes[0].element == "A")
			assert(s3.nodes[1].element == "B")
			assert(s3.nodes[2].element == "C")
			assert(s3.elements.available == false)
		}
		
		test("Multiple rule choice match.") {
			func t1(ch1:Character)(ch2:Character) -> Bool {
				return	ch1 == ch2
			}
			
			let	r1	=	Rule(significance: false, test: RuleTest.Atom(test: t1("A")))
			let	r2	=	Rule(significance: false, test: RuleTest.Atom(test: t1("B")))
			let	r3	=	Rule(significance: false, test: RuleTest.Atom(test: t1("C")))
			
			let	g1	=	"CBA".generate()
			let	es1	=	cursor(GeneratorOf<Element>(g1))
			let	rs1	=	cursor([r1, r2, r3])
			let	r4	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.Any, subrules: rs1))
			
			let	s0	=	r4.step(es1)
			///	Set to first rule "A".
			assert(s0.rules.current === r4)
			assert(s0.done == false)
			assert(s0.elements.current == "C")
			assert(s0.nodes.count == 0)
			
			var	s1	=	s0.continuation()
			///	Switched to next rule "B".
			assert(s1.rules.current === r4)
			assert(s1.done == false)
			assert(s1.elements.current == "C")
			assert(s1.nodes.count == 0)
			assert(s1.substep != nil)
			assert(s1.substep!.rules.current === r1)
			
			s1	=	s1.continuation()
			///	Switched to next rule "C".
			assert(s1.rules.current === r4)
			assert(s1.done == false)
			assert(s1.elements.current == "C")
			assert(s1.nodes.count == 0)
			assert(s1.substep != nil)
			tx {
				let	ss1	=	s1.substep!
				assert(ss1.rules.available == false)
				assert(ss1.done)
			}
			
			s1	=	s1.continuation()
			///	Switched to next rule "C".
			assert(s1.rules.available == false)
			assert(s1.done == true)
			assert(s1.elements.current == "B")
			assert(s1.nodes.count == 1)
			assert(s1.substep == nil)
			///	Finished because it's not repeated.
		}

		test("Multiple rule choice match with sequence.") {
			func t1(ch1:Character)(ch2:Character) -> Bool {
				return	ch1 == ch2
			}
			
			let	r1	=	Rule(significance: false, test: RuleTest.Atom(test: t1("A")))
			let	r2	=	Rule(significance: false, test: RuleTest.Atom(test: t1("B")))
			let	r3	=	Rule(significance: false, test: RuleTest.Atom(test: t1("C")))
			
			let	g1	=	"CBA".generate()
			let	es1	=	cursor(GeneratorOf<Element>(g1))
			let	rs1	=	cursor([r1, r2, r3])
			let	r4	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.Any, subrules: rs1))
			let	r5	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.Any, subrules: rs1))
			let	r6	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.All, subrules: cursor([r4, r5])))
			
			let	ees	=	TestHelper.currentElementsOfAllLayersOf

			var	s1	=	r6.step(es1)
			assert(ees(s1) == ["C"])
			
			s1	=	s1.continuation()
			assert(ees(s1) == ["C", "C"])
			
			s1	=	s1.continuation()
			assert(ees(s1) == ["C", "C", "C"])
			
			s1	=	s1.continuation()
			assert(ees(s1) == ["C", "C", "C"])
		}
//		test("Multiple rule choice match with sequence.") {
//			func t1(ch1:Character)(ch2:Character) -> Bool {
//				return	ch1 == ch2
//			}
//			
//			let	r1	=	Rule(significance: false, test: RuleTest.Atom(test: t1("A")))
//			let	r2	=	Rule(significance: false, test: RuleTest.Atom(test: t1("B")))
//			let	r3	=	Rule(significance: false, test: RuleTest.Atom(test: t1("C")))
//			
//			let	g1	=	"CBA".generate()
//			let	es1	=	cursor(GeneratorOf<Element>(g1))
//			let	rs1	=	cursor([r1, r2, r3])
//			let	r4	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.Any, subrules: rs1))
//			let	r5	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.Any, subrules: rs1))
//			let	r6	=	Rule(significance: false, test: RuleTest.Composition(mode: Mode.All, subrules: cursor([r4, r5])))
//			
//			let	ees	=	TestHelper.stepAllCurrentElementsOfAllLayers
//			
//			var	s0	=	r6.step(es1)
//			///	Set to first rule "A".
//			assert(s0.rules.current === r6)
//			assert(s0.done == false)
//			assert(s0.elements.current == "C")
//			assert(s0.nodes.count == 0)
//			assert(s0.substep == nil)
//			
//			var	s1	=	s0.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			
//			s1	=	s1.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			assert(s1.substep!.substep != nil)
//			assert(s1.substep!.substep!.elements.current == "C")
//			assert(s1.substep!.substep!.nodes.count == 0)
//			assert(s1.substep!.substep!.rules.current === r1)
//			
//			s1	=	s1.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			assert(s1.substep!.substep != nil)
//			assert(s1.substep!.substep!.elements.current == "C")
//			assert(s1.substep!.substep!.nodes.count == 0)
//			assert(s1.substep!.substep!.rules.available == false)
//			
//			s1	=	s1.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			println(s1.substep!.elements.current)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			assert(s1.substep!.substep != nil)
//			assert(s1.substep!.substep!.elements.current == "C")
//			assert(s1.substep!.substep!.nodes.count == 0)
//			assert(s1.substep!.substep!.rules.current === r2)
//			
//			s1	=	s1.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			assert(s1.substep!.substep != nil)
//			assert(s1.substep!.substep!.elements.current == "B")
//			assert(s1.substep!.substep!.nodes.count == 0)
//			assert(s1.substep!.substep!.rules.current === r3)
//			
//			s1	=	s1.continuation()
//			assert(s1.rules.current === r6)
//			assert(s1.done == false)
//			assert(s1.elements.current == "C")
//			assert(s1.nodes.count == 0)
//			assert(s1.substep != nil)
//			assert(s1.substep!.elements.current == "C")
//			assert(s1.substep!.nodes.count == 0)
//			assert(s1.substep!.rules.current === r4)
//			assert(s1.substep!.substep != nil)
//			assert(s1.substep!.substep!.elements.current == "B")
//			assert(s1.substep!.substep!.nodes.count == 0)
//			assert(s1.substep!.substep!.rules.available == false)
//			
//			s1	=	s1.continuation()
//			///	Switched to rule "C". 
//			///	Now it matched.
//			///	Element avanced to "B".
//			///	Stepped up.
//			assert(s1.done == false)
//			assert(s1.nodes.count == 1)
//			assert(s1.nodes[0].element == "C")
//			assert(s1.elements.current == "B")
//			assert(s1.substep == nil)
//			
//			s1	=	s1.continuation()
//			assert(s1.done == false)
//			assert(s1.nodes.count == 1)
//			assert(s1.nodes[0].element == "C")
//			assert(s1.elements.current == "B")
//			assert(s1.substep != nil)
//			assert(s1.substep?.elements.current == "C")
//			assert(s1.substep?.nodes.count == 0)
//			
//
//
//		}

	}
	
	
}

test()

















