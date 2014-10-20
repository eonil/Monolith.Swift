//
//  RFC4627.Operators.swift
//  Monolith
//
//  Created by Hoon H. on 10/21/14.
//
//

import Foundation

public func == (l:Standard.JSON.Value, r:Standard.JSON.Value) -> Bool {
	typealias	Value	=	Standard.JSON.Value
	
	switch (l,r) {
	case let (.Null, .Null):				return	true
	case let (.Boolean(l2),	.Boolean(r2)):	return	l2 == r2
	case let (.Number(l2),	.Number(r2)):	return	l2 == r2
	case let (.String(l2),	.String(r2)):	return	l2 == r2
	case let (.Array(l2),	.Array(r2)):	return	l2 == r2
	case let (.Object(l2),	.Object(r2)):	return	l2 == r2
	default:								return	false
	}
}
public func == (l:Standard.JSON.Number, r:Standard.JSON.Number) -> Bool {
	typealias	Value	=	Standard.JSON.Number
	
	switch (l,r) {
	case let (.Integer(l2), .Integer(r2)):	return	l2 == r2
	case let (.Float(l2),	.Float(r2)):	return	l2 == r2
	default:								return	false
	}
}
public func == (l:Standard.JSON.Value, r:()) -> Bool {
	return	l.null == true
}
public func == (l:Standard.JSON.Value, r:Bool) -> Bool {
	return	l.boolean == r
}
public func == (l:Standard.JSON.Value, r:Int64) -> Bool {
	if let v1 = l.number?.integer {
		return	v1 == r
	}
	return	false
}
public func == (l:Standard.JSON.Value, r:Float64) -> Bool {
	if let v1 = l.number?.float {
		return	v1 == r
	}
	return	false
}
public func == (l:Standard.JSON.Value, r:String) -> Bool {
	return	l.string == r
}
