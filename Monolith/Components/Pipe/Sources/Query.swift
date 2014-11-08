//
//  QueryType.swift
//  AsynchronousFramework
//
//  Created by Hoon H. on 11/4/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation











///	Transforms signal streams.
///
///	Pull-based signaling node.
public protocol QueryType {
	typealias	In
	typealias	Out
	func evaluate(In)->(Out)
}









///	Creates a filter from a function.
///	This is also useful to hide complex filter types from the user.
public struct QueryOf<I,O>: QueryType {
	let	filter:(I)->(O)
	
	public init(filter:(I)->(O)) {
		self.filter	=	filter
	}
	
	public func evaluate(s:I) -> O {
		return	filter(s)
	}
}

///	Creates a filter by piping two filters.
public struct QueryFlow<F1:QueryType, F2:QueryType where F1.Out == F2.In> : QueryType {
	let	left:F1
	let	right:F2
	
	public func evaluate(s:F1.In) -> F2.Out {
		return	right.evaluate(left.evaluate(s))
	}
}

///	An absorber (terminal filter) which routes input signal to
///	all suppleid filters. Supplied filters must take same input
///	signal, and emit nothing. (terminal)
public struct MulticastQuery<F:QueryType> : QueryType {
	let	all:[F]
	
	public func evaluate(s:F.In) -> () {
		for f in all {
			f.evaluate(s)
		}
	}
}





///	Pipe by unicast.
public func >>> <F1:QueryType, F2:QueryType where F1.Out == F2.In> (left:F1, right:F2) -> QueryFlow<F1, F2> {
	return	QueryFlow<F1, F2>(left: left, right: right)
}

///	Pipe by multicast.
public func >>> <F1:QueryType, F2:QueryType where F1.Out == F2.In> (left:F1, right:[F2]) -> QueryFlow<F1, MulticastQuery<F2>> {
	let	m1	=	MulticastQuery<F2>(all: right)
	return	QueryFlow<F1, MulticastQuery<F2>>(left: left, right: m1)
}

///	Pipe from an input value.
public func >>> <F:QueryType> (left:F.In, right:F) -> QueryFlow<Emitter<F.In>, F> {
	let	f1	=	Emitter(left)
	return	QueryFlow<Emitter<F.In>, F>(left: f1, right: right)
}

///	Pipe to a terminal output function.
public func >>> <F:QueryType> (left:F, right:F.Out->()) -> QueryFlow<F, QueryOf<F.Out,()>> {
	let	f2	=	QueryOf<F.Out,()> { right($0) }
	return	QueryFlow<F, QueryOf<F.Out,()>>(left: left, right: f2)
}























///	MARK:
///	Presets
///	MARK:

public func query<T,U>(f:T->U) -> QueryOf<T,U> {
	return	QueryOf(f)
}


//public func absorb<T>(f:T->()) -> QueryType {
//	let	f1	=	FilterOf { return f() }
//	return	f1
//}










