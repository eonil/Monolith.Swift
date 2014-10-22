////
////  main.swift
////  Text3
////
////  Created by Hoon H. on 10/22/14.
////
////
//
//import Foundation
//
//println("Hello, World!")
//
//
//
//
//struct Status {
//}
//
//protocol DataStorage {
//	
//}
//struct DataStorageOf<T> {
//	typealias	Element	=	T
//}
//
//
//protocol CursorType {
//	typealias	Element
//	func current() -> Element
//	func continuation() -> CursorType
//}
//struct CursorOf<T>: CursorType {
//	let	generator:GeneratorOf<T>
//	func current() -> Element {
//	}
//}
//
//
//
//protocol RuleType {
//	func run(cursor:CursorType) -> Status
//}
//
/////	All rules produce nodes.
/////	Components are joined togather at flat layer.
/////	Some rules may produce node.
//class Rule<T> : RuleType {
//	let	significant		=	false							///<	Makes produced node as significant so will not be discarded at super-rule composition stage.
//	let	subrules		=	GeneratorOfOne<Rule<T>>(nil)
//
//	func run(cursor: CursorType) -> Status {
//		fatalError("Unimpl")
//	}
//}
//
//enum RuleIterationMode {
//	case All	///<	Matches all elements in iteration.
//	case Any	///<	Matches any (one) elements in iteration.
//}
//struct RuleIterationOptions {
//	let	occurrences	=	Occurrences(minimum: nil, maximum: nil)
//	struct Occurrences {
//		let	minimum:Int?
//		let	maximum:Int?
//	}
//}
////enum RuleIterationStep<T> {
////	typealias	Parameters	=	(mode:RuleIterationMode, options:RuleIterationOptions, location:GeneratorOf<Rule<T>>)
////	typealias	Production	=	(substatus:[RuleIterationStatus<T>], subnodes:[Node<T>])
////	
////	case ProcessingSubrule
////	case Step(Parameters,Production)
////	case Done(Production)
////	
////	func step() -> RuleIterationStep {
////		switch self {
////		case let Step(s):
////			
////		case let Done(s):
////		}
////	}
////}
//
/////	(Cursor<Element>, Cursor<Rule>) -> Node
//struct RuleIterationState<T> {
//	///	Input parameters.
//	let	mode:		RuleIterationMode
//	let	options:	RuleIterationOptions
//	let	location:	GeneratorOf<Rule<T>>
//	let	scanning:	GeneratorOf<T>
//	
//	///	Processing context information.
//	let	processing:	(rule:Rule<T>, state:RuleIterationState<T>)?	///<	If a subrule is on-iterating, this value will be set.
//	
//	///	Output productions.
//	var	status:		[RuleIterationStatus<T>]
//	var	subnodes:	[Node<T>]
//	
//	func step() -> RuleIterationState {
//		if let p1 = processing {
//			
//		}
//	}
//}
//enum RuleIterationStatus<T> {
//	case None
//	case Done
//}
//
//
//
////class Analysis<T> {
////	let	layers	=	[] as [AnalysisLayer<T>]
////	
////	func step() -> Analysis {
////		
////	}
////}
////
///////	A box for optimisation.
////class AnalysisLayer<T> {
////	let	state:RuleIterationState<T>
////	
////	init(state:RuleIterationState<T>) {
////		self.state	=	state
////	}
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
//class IterationRule<T> : Rule<T> {
//	let	mode:RuleIterationMode
//	let	run:GeneratorOf<Rule<T>>
//	
//	init(mode:RuleIterationMode, run:GeneratorOf<Rule<T>>) {
//		self.mode	=	mode
//		self.run	=	run
//	}
//	func step() -> RuleIterationState<T> {
//		
//	}
//	override func run(cursor: CursorType) -> Status {
//		
//	}
//}
//
//class SequenceRule<T> : IterationRule<T> {
//	
//}
//class ChoiceRule<T> : IterationRule<T> {
//	let	run:GeneratorOf<Rule<T>>
//	
//	init() {
//		
//	}
//}
//
//
//
//
//
//
//
//
//class Node<T> {
//	
//}
//
//
//
//
//
//
//
