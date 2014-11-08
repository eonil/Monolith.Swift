//
//  Presets.swift
//  Pipe
//
//  Created by Hoon H. on 11/8/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation













///	MARK:
///	MARK:	Query/Task Presets
///	MARK:



///	Produces a value infinitely.
public struct Emitter<T> : QueryType, TaskType {
	let	value:T
	public init(_ v:T) {
		value	=	v
	}
	public func dispatch(signal: (), _ observer: T -> ()) {
		observer(value)
	}
//	public func dispatch(signal: (), _ observer: T -> ()) -> Cancel {
//		observer(value)
//		return	NOOP
//	}
	public func evaluate(_: ()) -> (T) {
		return	value
	}
}

///	Consumes a value with no result.
public struct Absorber<T> : QueryType, TaskType {
	public func dispatch(signal: T, _ observer: () -> ()) {
		observer()
	}
//	public func dispatch(signal: T, _ observer: () -> ()) -> Cancel {
//		observer()
//		return	NOOP
//	}
	public func evaluate(_: T) -> () {
		return	NOOP()
	}
}


//public struct NilAbsorberTask<T> : TaskType, NilLiteralConvertible {
//	public init(nilLiteral: ()) {
//	}
//	public func dispatch(signal: T, _ observer: () -> ()) -> Cancel {
//		observer()
//		return	NOOP
//	}
//}








///	A node to run arbitrary function.
public struct Evalute<I,O> : QueryType, TaskType {
	public let	filter:I->O
	public init(_ filter:I->O) {
		self.filter	=	filter
	}
	public func dispatch(signal: I, _ observer: O -> ()) {
		signal >>> filter >>> observer
	}
//	public func dispatch(signal: IN, _ observer: OUT -> ()) -> Cancel {
//		signal >>> filter >>> observer
//		return	NOOP
//	}
	public func evaluate(v: I) -> (O) {
		return	filter(v)
	}
}













///	MARK:
///	MARK:	Task-Only Presets
///	MARK:

///	Delays all signals for specified time.
///	This possibly make one thread for each signal,
///	and should be avoided.
public final class Delay<T> : TaskType {
	private let	_core	=	_DelayCore()
	
	public init(_ s:NSTimeInterval) {
		_core.seconds	=	s
	}
	deinit {
		_core.halt.compareAndSwapBarrier(oldValue: false, newValue: true)
		for s1 in _core.semaphores {
			s1.signal()
		}
	}
	public func dispatch(signal:T, _ observer:T->()) {
		let	c1	=	_core
		let	s1	=	Semaphore()
		c1.semaphores.append(s1)
		//
		//	Do not let the closure to capture the `self` for correct deinitialisation timing.
		//
		Dispatch.backgroundConcurrently { () -> () in
			s1.wait(c1.seconds)
			c1.semaphores	=	c1.semaphores.filter {$0 !== s1}
			if c1.halt.value == false {
				observer(signal)
			}
		}
	}
}

private final class _DelayCore {
	var	seconds		=	0 as NSTimeInterval
	var	semaphores	=	[] as [Semaphore]
	var	halt		=	AtomicBoolSlot(false)
}



/////	Waits for constant time. Signal will be passed through.
//public struct ConstantTimeWaitTask<T> : TaskType {
//	let	seconds:NSTimeInterval
//	public init(_ seconds:NSTimeInterval) {
//		self.seconds	=	seconds
//	}
//	deinit {
//		
//	}
//	public func dispatch(signal: T, _ observer: T -> ()) {
//		let	w1	=	ShortWaitingRepeater()
//		w1.resetTimeBySeconds(seconds)
//		w1.waitAndRun {observer(signal)}
//		return	{
//			w1.stopAsSoonAsPossible()
//		}
//	}
////	public func dispatch(signal: T, _ observer: T->()) -> Cancel {
////		let	w1	=	ShortWaitingRepeater()
////		w1.resetTimeBySeconds(seconds)
////		w1.waitAndRun {observer(signal)}
////		return	{
////			w1.stopAsSoonAsPossible()
////		}
////	}
//}
//
/////	Waits for parametric time. The time parameter should be
/////	passed a part of signal.
//public struct ParametricTimeWaitTask<T> : TaskType {
//	public init() {
//	}
//	public func dispatch(signal: T, _ observer: T -> ()) {
//		let	w1	=	ShortWaitingRepeater()
//		w1.resetTimeBySeconds(signal.time)
//		w1.waitAndRun {observer(signal.value)}
//		return	{
//			w1.stopAsSoonAsPossible()
//		}
//	}
////	public func dispatch(signal: TimeSignal<T>, _ observer: T->()) -> Cancel {
////		let	w1	=	ShortWaitingRepeater()
////		w1.resetTimeBySeconds(signal.time)
////		w1.waitAndRun {observer(signal.value)}
////		return	{
////			w1.stopAsSoonAsPossible()
////		}
////	}
//}
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
public struct DynamicTask<I,O> : TaskType {
	let	resolve:()->TaskOf<I,O>
	public init(_ resolve:()->TaskOf<I,O>) {
		self.resolve	=	resolve
	}
	public func dispatch(signal: I, _ observer: O->()) {
		return	resolve().dispatch(signal, observer)
	}
//	public func dispatch(signal: IN, _ observer: OUT -> ()) -> Cancel {
//		return	resolve().dispatch(signal, observer)
//	}
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
//