//
//  Operators.swift
//  Monolith
//
//  Created by Hoon H. on 10/18/14.
//
//

import Foundation


///
///	Global operators.
///



import Foundation





infix operator ||| {

}

///	*nil-or* operator.
///
///		let	c	=	a ||| b
///
///	`c` becomes `a` if `a` is non-`nil` value, or `b` otherwise.
///	`a` must be nillable type, and `b` must be non-nillable type.
public func ||| <T> (left:T?, right:T) -> T {
	if left == nil {
		return	right
	} else {
		return	left!
	}
}



/////	Pipe operator works as applying a function to a value and returns a value.
//func | <T,U> (left:T, right:(T)->U) -> U {
//	return	right(left)
//}
/////	Pipe operator works as applying a function to a value.
//func | <T> (left:T, right:(T)->()) {
//	right(left)
//}

