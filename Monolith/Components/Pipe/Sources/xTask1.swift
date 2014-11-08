////
////  Task.swift
////  AsynchronousFramework
////
////  Created by Hoon H. on 11/4/14.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
//public typealias	Cancel	=	()->()
//
//
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
//public protocol TaskType {
//	typealias	In
//	typealias	Out
//	
//	func dispatch(signal:In, _ observer:Out->()) -> Cancel
//}
//
//public struct TaskOf<I,O> {
//	let	dispatch:(signal:I, observer:O->()) -> Cancel
//	public init(dispatch:(signal:I, observer:O->()) -> Cancel) {
//		self.dispatch	=	dispatch
//	}
//	public func dispatch(signal:I, _ observer:O->()) -> Cancel {
//		return	dispatch(signal: signal, observer: {
//			observer($0)
//		})
//	}
//}
//
/////	A combined asynchronous task.
//public struct ContinuationTask<F1:TaskType, F2:TaskType where F1.Out == F2.In> : TaskType {
//	let	left:F1
//	let	right:F2
//	
//	public func dispatch(signal: F1.In, _ observer: F2.Out -> ()) -> Cancel {
//		var	cancel1	=	NOOP
//		var	cancel2	=	NOOP
//		var	abort	=	false
//		let	totalCancel	=	{
//			abort	=	true
//			cancel1()
//			cancel2()
//		} as ()->()
//		cancel1	=	left.dispatch(signal) { (s2:F1.Out)->() in
//			cancel1	=	NOOP
//			if abort == false {
//				cancel2	=	self.right.dispatch(s2) { (s3:F2.Out)->() in
//					cancel2	=	NOOP
//					observer(s3)
//				}
//			}
//		}
//		return	totalCancel
//	}
//}
//
//public struct MulticastingTask<T:TaskType> : TaskType {
//	let	all:[T]
//	public init(_ a:[T]) {
//		all	=	a
//	}
//	public func dispatch(signal: T.In, _ observer: T.Out -> ()) -> Cancel {
//		var	subcancels	=	[Cancel](count: all.count, repeatedValue: NOOP)
//		var	abort		=	false
//		let	cancelAll	=	{
//			abort		=	true
//			for c in subcancels {
//				c()
//			}
//		} as Cancel
//		for (idx,t) in enumerate(all) {
//			subcancels[idx]	=
//			t.dispatch(signal) { (s2:T.Out)->() in
//				subcancels[idx]	=	NOOP
//				observer(s2)
//			}
//		}
//		return	cancelAll
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
//
///////	Asynchronous pipe operator.
////infix operator ~~> {
////	associativity left
////}
////
///////	Pipe by asynchronous unicast.
///////	Intentionally uses different operator with synchronous pipe.
////public func ~~> <F1:TaskType, F2:TaskType where F1.Out == F2.In> (left:F1, right:F2) -> ContinuationTask<F1, F2> {
////	return	ContinuationTask<F1, F2>(left: left, right: right)
////}
//
/////	Pipe by asynchronous unicast.
//public func >>> <F1:TaskType, F2:TaskType where F1.Out == F2.In> (left:F1, right:F2) -> ContinuationTask<F1, F2> {
//	return	ContinuationTask<F1, F2>(left: left, right: right)
//}
//
/////	Pipe by asynchronous multicast.
//public func >>> <F1:TaskType, F2:TaskType where F1.Out == F2.In> (left:F1, right:[F2]) -> ContinuationTask<F1, MulticastingTask<F2>> {
//	return	ContinuationTask<F1, MulticastingTask<F2>>(left: left, right: MulticastingTask(right))
//}
//
/////	Pipe from a value.
//public func >>> <T:TaskType> (left:T.In, right:T) -> ContinuationTask<Emitter<T.In>, T> {
//	return	ContinuationTask<Emitter<T.In>, T>(left: Emitter<T.In>(left), right: right)
//}
//
///////	Pipe to nil.
////public func >>> <T:TaskType> (left:T, right:NilAbsorberTask<T.Out>) -> Absorber<T.In> {
////	let	c1	=	ContinuationTask<T, NilAbsorberTask<T.Out>>(left: left, right: right)
////	let	t1	=	task(c1)
////	return	Absorber(task: t1)
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
//public func task<I,O>(f:(signal:I, observer:O->()) -> Cancel) -> TaskOf<I,O> {
//	return	TaskOf(dispatch: f)
//}
//public func task<T:TaskType>(t:T) -> TaskOf<T.In,T.Out> {
//	let	d1	=	{ (signal:T.In, observer:T.Out->()) -> Cancel in
//		return	t.dispatch(signal, observer)
//	}
//	return	TaskOf(dispatch: d1)
//}
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
//
//
//
//
//
//
//
//
