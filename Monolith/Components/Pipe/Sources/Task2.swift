//
//  Cancellable.swift
//  Pipe
//
//  Created by Hoon H. on 11/8/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

///	A task performs asynchronous processing and calls observer to
///	notify the result signal. A input singla may produce multiple
///	output signal and vice versa.
///
///	A task must stop all operation and clean up all resources 
///	immdediately when the task is being destroyed. Any
///	asynchronous operation or thread execution shouldn't continue
///	after stopping. Also, no signal can be fired after destruction.
///
/////	Accepts input and produces an async outputs.
/////	Unlike filters, occurrences of input and output
/////	are asymmetric. One input can make
/////	multiple output, and multiple input can make single
/////	output. It's fully up to each node's definition.
/////	Of course some channel guarantee symmetric
/////	input/output occurrences.
/////	Input/output can occur in different threads. Any
/////	thread. So do not make any assumption on which
/////	thread to call the observer.
/////
/////	This is a push based signaling node.
public protocol TaskType {
	typealias	In
	typealias	Out
	
	func dispatch(In,(Out->()))->()
}
public struct TaskOf<I,O> {
	private let	_dispatch:(I,O->())->()
	public init(f:(I,O->())->()) {
		self._dispatch	=	f
	}
	public func dispatch(signal:I, _ observer:O->()) {
		_dispatch(signal, observer)
	}
}






public struct ContinuationTask<T1:TaskType,T2:TaskType where T1.Out == T2.In> : TaskType {
	let	left:T1
	let	right:T2
	public func dispatch(signal: T1.In, _ observer: T2.Out->()) {
		left.dispatch(signal) { signal2 in
			self.right.dispatch(signal2, observer)
		}
	}
}
public struct MulticastingTask<T:TaskType> : TaskType {
	let	all:[T]
	public init(_ a:[T]) {
		all	=	a
	}
	public func dispatch(signal: T.In, _ observer: T.Out -> ()) {
		for (_,t) in enumerate(all) {
			t.dispatch(signal) { s2 in
				observer(s2)
			}
		}
	}
}

	
	
	
	
	
	
	

///	Pipe by asynchronous unicast.
public func >>> <F1:TaskType, F2:TaskType where F1.Out == F2.In> (left:F1, right:F2) -> ContinuationTask<F1, F2> {
	return	ContinuationTask<F1, F2>(left: left, right: right)
}

///	Pipe by asynchronous multicast.
public func >>> <F1:TaskType, F2:TaskType where F1.Out == F2.In> (left:F1, right:[F2]) -> ContinuationTask<F1, MulticastingTask<F2>> {
	return	ContinuationTask<F1, MulticastingTask<F2>>(left: left, right: MulticastingTask(right))
}

///	Pipe from a value.
public func >>> <T:TaskType> (left:T.In, right:T) -> ContinuationTask<Emitter<T.In>, T> {
	return	ContinuationTask<Emitter<T.In>, T>(left: Emitter<T.In>(left), right: right)
}

/////	Pipe to nil.
//public func >>> <T:TaskType> (left:T, right:NilAbsorberTask<T.Out>) -> Absorber<T.In> {
//	let	c1	=	ContinuationTask<T, NilAbsorberTask<T.Out>>(left: left, right: right)
//	let	t1	=	task(c1)
//	return	Absorber(task: t1)
//}










public func task<I,O>(f:(signal:I, observer:O->())->()) -> TaskOf<I,O> {
	return	TaskOf(f)
}
//public func task<T:TaskType>(t:T) -> TaskOf<T.In,T.Out> {
////	let	d1	=	{ signal in
////		return	t.dispatch(signal, observer)
////	}
////	return	TaskOf(dispatch: d1)
//	
//	return	TaskOf(dispatch: <#(signal: I, observer: O -> ())#>)
//}





	
	
	
	
	
	
	
	

















