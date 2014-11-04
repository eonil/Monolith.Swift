//
//  FilterAndPipe.swift
//  AsynchronousFramework
//
//  Created by Hoon H. on 11/4/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation





///////////////////////////////////////////////////////////////////////////////////////////////
///
///	As you know, synchronous filter is useless unless you want some dynamic filter programming.
///	Because just writing plain code provides all synchronous filtering.
///
///////////////////////////////////////////////////////////////////////////////////////////////








///	Transforms signal streams
public protocol SynchronousFilter {
	typealias	IN
	typealias	OUT
	func signal(s:IN)->OUT
}

///	Emits signal streams.
public protocol SynchronousEmitter: SynchronousFilter {
	typealias	IN	=	()
	typealias	OUT
}

///	Emits signal streams.
public protocol SynchronousAbsorber: SynchronousFilter {
	typealias	OUT	=	()
	typealias	IN
}








///	Creates a filter from a function.
///	This is also useful to hide complex filter types from the user.
public struct SynchronousFilterOf<IN,OUT>: SynchronousFilter {
	let	filter:(IN)->(OUT)
	
	public init(filter:(IN)->(OUT)) {
		self.filter	=	filter
	}
	
	public func signal(s:IN) -> OUT {
		return	filter(s)
	}
}

///	Creates a filter by piping two filters.
public struct SynchronousFlow<F1:SynchronousFilter, F2:SynchronousFilter where F1.OUT == F2.IN> : SynchronousFilter {
	let	left:F1
	let	right:F2
	
	public func signal(s:F1.IN) -> F2.OUT {
		return	right.signal(left.signal(s))
	}
}

///	An absorber (terminal filter) which routes input signal to
///	all suppleid filters. Supplied filters must take same input
///	signal, and emit nothing. (terminal)
public struct SynchronousMulticast<F:SynchronousFilter> : SynchronousFilter {
	let	all:[F]
	
	public func signal(s:F.IN) -> () {
		for f in all {
			f.signal(s)
		}
	}
}





///	Pipe by unicast.
public func >>> <F1:SynchronousFilter, F2:SynchronousFilter where F1.OUT == F2.IN> (left:F1, right:F2) -> SynchronousFlow<F1, F2> {
	return	SynchronousFlow<F1, F2>(left: left, right: right)
}

///	Pipe by multicast.
public func >>> <F1:SynchronousFilter, F2:SynchronousFilter where F1.OUT == F2.IN> (left:F1, right:[F2]) -> SynchronousFlow<F1, SynchronousMulticast<F2>> {
	let	m1	=	SynchronousMulticast<F2>(all: right)
	return	SynchronousFlow<F1, SynchronousMulticast<F2>>(left: left, right: m1)
}

///	Pipe from an input value.
public func >>> <F:SynchronousFilter> (left:F.IN, right:F) -> SynchronousFlow<SynchronousConstantEmitter<F.IN>, F> {
	let	f1	=	SynchronousConstantEmitter(left)
	return	SynchronousFlow<SynchronousConstantEmitter<F.IN>, F>(left: f1, right: right)
}

///	Pipe to a terminal output function.
public func >>> <F:SynchronousFilter> (left:F, right:F.OUT->()) -> SynchronousFlow<F, SynchronousFilterOf<F.OUT,()>> {
	let	f2	=	SynchronousFilterOf<F.OUT,()> { right($0) }
	return	SynchronousFlow<F, SynchronousFilterOf<F.OUT,()>>(left: left, right: f2)
}























///	MARK:
///	Presets
///	MARK:


public struct SynchronousConstantEmitter<T> : SynchronousFilter {
	let	value:T
	public init(_ value:T) {
		self.value	=	value
	}
	public func signal(_:()) -> T {
		return	value
	}
}

public struct SynchronousVoidAbsorber<T> : SynchronousFilter {
	public func signal(_:T) -> () {
	}
}






public func synchronousFilter<T,U>(f:T->U) -> SynchronousFilterOf<T,U> {
	return	SynchronousFilterOf(f)
}


//public func absorb<T>(f:T->()) -> SynchronousFilter {
//	let	f1	=	FilterOf { return f() }
//	return	f1
//}










