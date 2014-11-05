//
//  Task.swift
//  AsynchronousFramework
//
//  Created by Hoon H. on 11/4/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation



public typealias	Cancel	=	()->()


///	Accepts input and produces an async outputs.
///	Unlike filters, occurrences of input and output
///	are asymmetric. One input can make
///	multiple output, and multiple input can make singl
///	output. It's fully up to channel definition. Of course
///	some channel can guarantee symmetric input/output
///	occurrences. This can be checked dynamically.
public protocol Task {
	typealias	IN
	typealias	OUT

	func dispatch(signal:IN, _ observer:OUT->()) -> Cancel
}

public struct TaskOf<IN,OUT> {
	let	dispatch:(signal:IN, observer:OUT->()) -> Cancel
	private let	_cancelBox	=	VariableBox(NOOP)
	public init(dispatch:(signal:IN, observer:OUT->()) -> Cancel) {
		self.dispatch	=	dispatch
	}
	public func dispatch(signal:IN, _ observer:OUT->()) -> Cancel {
		return	dispatch(signal: signal, observer: {
 			self._cancelBox.value	=	NOOP
			observer($0)
		})
	}
}

///	A combined asynchronous task.
public struct ContinuationTask<F1:Task, F2:Task where F1.OUT == F2.IN> : Task {
	let	left:F1
	let	right:F2
	
	public func dispatch(signal: F1.IN, _ observer: F2.OUT -> ()) -> Cancel {
		var	cancel1	=	NOOP
		var	cancel2	=	NOOP
		var	abort	=	false
		let	totalCancel	=	{
			abort	=	true
			cancel1()
			cancel2()
		} as ()->()
		cancel1	=	left.dispatch(signal) { (s2:F1.OUT)->() in
			cancel1	=	NOOP
			if abort == false {
				cancel2	=	self.right.dispatch(s2) { (s3:F2.OUT)->() in
					cancel2	=	NOOP
					observer(s3)
				}
			}
		}
		return	totalCancel
	}
}

public struct MulticastingTask<T:Task> : Task {
	let	all:[T]
	public init(_ a:[T]) {
		all	=	a
	}
	public func dispatch(signal: T.IN, _ observer: T.OUT -> ()) -> Cancel {
		var	subcancels	=	[Cancel](count: all.count, repeatedValue: NOOP)
		var	abort		=	false
		let	cancelAll	=	{
			abort		=	true
			for c in subcancels {
				c()
			}
		} as Cancel
		for (idx,t) in enumerate(all) {
			subcancels[idx]	=
			t.dispatch(signal) { (s2:T.OUT)->() in
				subcancels[idx]	=	NOOP
				observer(s2)
			}
		}
		return	cancelAll
	}
}



public struct Absorber<T> {
	let	task:TaskOf<T,()>
	public func dispatch(v:T) -> Cancel {
		return	task.dispatch(v, NOOP)
	}
}






///	Asynchronous pipe operator.
infix operator ~~> {
	associativity left
}

///	Pipe by asynchronous unicast.
///	Intentionally uses different operator with synchronous pipe.
public func ~~> <F1:Task, F2:Task where F1.OUT == F2.IN> (left:F1, right:F2) -> ContinuationTask<F1, F2> {
	return	ContinuationTask<F1, F2>(left: left, right: right)
}

///	Pipe by asynchronous unicast.
public func >>> <F1:Task, F2:Task where F1.OUT == F2.IN> (left:F1, right:F2) -> ContinuationTask<F1, F2> {
	return	ContinuationTask<F1, F2>(left: left, right: right)
}

///	Pipe by asynchronous multicast.
public func >>> <F1:Task, F2:Task where F1.OUT == F2.IN> (left:F1, right:[F2]) -> ContinuationTask<F1, MulticastingTask<F2>> {
	return	ContinuationTask<F1, MulticastingTask<F2>>(left: left, right: MulticastingTask(right))
}

///	Pipe from a value.
public func >>> <T:Task> (left:T.IN, right:T) -> ContinuationTask<ValueEmitterTask<T.IN>, T> {
	return	ContinuationTask<ValueEmitterTask<T.IN>, T>(left: ValueEmitterTask<T.IN>(left), right: right)
}

/////	Pipe to nil.
//public func >>> <T:Task> (left:T, right:NilAbsorberTask<T.OUT>) -> Absorber<T.IN> {
//	let	c1	=	ContinuationTask<T, NilAbsorberTask<T.OUT>>(left: left, right: right)
//	let	t1	=	task(c1)
//	return	Absorber(task: t1)
//}










public func task<IN,OUT>(f:(signal:IN, observer:OUT->()) -> Cancel) -> TaskOf<IN,OUT> {
	return	TaskOf(dispatch: f)
}
public func task<T:Task>(t:T) -> TaskOf<T.IN,T.OUT> {
	let	d1	=	{ (signal:T.IN, observer:T.OUT->()) -> Cancel in
		return	t.dispatch(signal, observer)
	}
	return	TaskOf(dispatch: d1)
}






















///	MARK:
///	MARK:	Presets
///	MARK:

///	Produces a value infinitely.
public struct ValueEmitterTask<T> : Task {
	let	value:T
	public init(_ v:T) {
		value	=	v
	}
	public func dispatch(signal: (), _ observer: T -> ()) -> Cancel {
		observer(value)
		return	NOOP
	}
}

///	Consumes a value with no result.
public struct ValueAbsorberTask<T> : Task {
	public func dispatch(signal: T, _ observer: () -> ()) -> Cancel {
		observer()
		return	NOOP
	}
}

//public struct NilAbsorberTask<T> : Task, NilLiteralConvertible {
//	public init(nilLiteral: ()) {
//	}
//	public func dispatch(signal: T, _ observer: () -> ()) -> Cancel {
//		observer()
//		return	NOOP
//	}
//}



///	An asynchronous task to run synchronous filter.
public struct Step<IN,OUT> : Task {
	public let	filter:IN->OUT
	public init(filter:IN->OUT) {
		self.filter	=	filter
	}
	public func dispatch(signal: IN, _ observer: OUT -> ()) -> Cancel {
		signal >>> filter >>> observer
		return	NOOP
	}
}

///	Waits for constant time. Signal will be passed through.
public struct ConstantTimeWaitTask<T> : Task {
	let	seconds:NSTimeInterval
	public init(_ seconds:NSTimeInterval) {
		self.seconds	=	seconds
	}
	public func dispatch(signal: T, _ observer: T->()) -> Cancel {
		let	w1	=	ShortWaitingRepeater()
		w1.resetTimeBySeconds(seconds)
		w1.waitAndRun {observer(signal)}
		return	{
			w1.stopAsSoonAsPossible()
		}
	}
}

///	Waits for parametric time. The time parameter should be
///	passed a part of signal.
public struct ParametricTimeWaitTask<T> : Task {
	public init() {
	}
	public func dispatch(signal: TimeSignal<T>, _ observer: T->()) -> Cancel {
		let	w1	=	ShortWaitingRepeater()
		w1.resetTimeBySeconds(signal.time)
		w1.waitAndRun {observer(signal.value)}
		return	{
			w1.stopAsSoonAsPossible()
		}
	}
}
public struct TimeSignal<T> {
	public let	time:NSTimeInterval
	public let	value:T
	
	public init(time:NSTimeInterval, value:T) {
		self.time	=	time
		self.value	=	value
	}
}

///	Runs dynamically resolved subtask.
///	You can build up a loop using this.
///	With combining a condition branch, 
///	task-framework becomes turing-complete.
public struct DynamicTask<IN,OUT> : Task {
	let	resolve:()->TaskOf<IN,OUT>
	public init(_ resolve:()->TaskOf<IN,OUT>) {
		self.resolve	=	resolve
	}
	public func dispatch(signal: IN, _ observer: OUT -> ()) -> Cancel {
		return	resolve().dispatch(signal, observer)
	}
}
























///	MARK:
///	MARK:	Privates
///	MARK:

private final class ShortWaitingRepeater {
	let	resolutionInNanoseconds	=	Int64(NSEC_PER_SEC)/100 as Int64
	var	timeToGoInNanoseconds	=	0 as Int64
	
	var waiting:Bool {
		get {
			assert(resolutionInNanoseconds != 0)
			return	timeToGoInNanoseconds > 0
		}
	}
	func resetTimeBySeconds(seconds:NSTimeInterval) {
		self.timeToGoInNanoseconds		=	Int64(seconds * NSTimeInterval(NSEC_PER_SEC))
	}
	func waitAndRun(f:()->()) {
		assert(resolutionInNanoseconds != 0)
		
		if timeToGoInNanoseconds == 0 {
			f()
			return
		} else {
			let	turnTime	=	timeToGoInNanoseconds > resolutionInNanoseconds ? resolutionInNanoseconds : timeToGoInNanoseconds
			timeToGoInNanoseconds	-=	turnTime
			
			weak var	weakSelf	=	self
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, turnTime), dispatch_get_main_queue(), {
				weakSelf?.waitAndRun(f)
				return
			})
		}
	}
	func stopAsSoonAsPossible() {
		timeToGoInNanoseconds	=	0
	}
}

private class VariableBox<T> {
	var	value:T
	init(_ value:T) {
		self.value	=	value
	}
}

private func NOOP() {
}




