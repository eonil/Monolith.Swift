//
//  Pipe.swift
//  AsynchronousFramework
//
//  Created by Hoon H. on 11/4/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


///	Pipe operator.
infix operator >>> {
associativity left
precedence 140
}

///	Pipe functions synchronously. Take care that this will not be exposed publicly.
public func >>> <T,U> (left:T, right:(T)->(U)) -> U {
	return	right(left)
}

