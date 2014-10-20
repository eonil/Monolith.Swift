//
//  RFC4627.Literals.swift
//  Monolith
//
//  Created by Hoon H. on 10/21/14.
//
//

import Foundation

extension Standard.RFC4627.Value : NilLiteralConvertible, BooleanLiteralConvertible, IntegerLiteralConvertible, FloatLiteralConvertible, StringLiteralConvertible, ExtendedGraphemeClusterLiteralConvertible, UnicodeScalarLiteralConvertible, ArrayLiteralConvertible, DictionaryLiteralConvertible {
	public typealias	Key		=	Standard.RFC4627.SwiftString
	public typealias	Value	=	Standard.RFC4627.Value
	public typealias	Element	=	Standard.RFC4627.Value
	
	public init(nilLiteral: ()) {
		self	=	Value.Null
	}
	public init(booleanLiteral value: BooleanLiteralType) {
		self	=	Value.Boolean(value)
	}
	public init(integerLiteral value: IntegerLiteralType) {
		self	=	Value.Number(Standard.RFC4627.Number.Integer(Int64(value)))
	}
	public init(floatLiteral value: FloatLiteralType) {
		self	=	Value.Number(Standard.RFC4627.Number.Float(Float64(value)))
	}
	public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterType) {
		self.init(stringLiteral: value)
	}
	public init(stringLiteral value: StringLiteralType) {
		self	=	Value.String(value)
	}
	public init(unicodeScalarLiteral value: UnicodeScalarType) {
		self.init(stringLiteral: value)
	}
	public init(arrayLiteral elements: Element...) {
		self	=	Value.Array(elements)
	}
	public init(dictionaryLiteral elements: (Key, Value)...) {
		var	o1	=	[:] as [Key:Value]
		for (k,v) in elements {
			o1[k]	=	v
		}
		self	=	Value.Object(o1)
	}
}


