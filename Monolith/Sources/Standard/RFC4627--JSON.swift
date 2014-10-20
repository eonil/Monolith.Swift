//
//  RFC4627.swift
//  Monolith
//
//  Created by Hoon H. on 10/20/14.
//
//

import Foundation

public extension Standard {
	public typealias	JSON	=	RFC4627

	public struct RFC4627 {
	}
}

public extension Standard.RFC4627 {
	typealias	SwiftString	=	String	///	There should be a better way than this...
	
	///	Explicitly typed representation.
	public enum Value : Equatable {
		case Object([SwiftString:Value])
		case Array([Value])
		case String(SwiftString)
		case Number(Standard.RFC4627.Number)
		case Boolean(Bool)
		case Null
		
		public var object:[SwiftString:Value]? {
			get {
				switch self {
				case let Object(state):		return	state
				default:					return	nil
				}
			}
		}
		public var array:[Value]? {
			get {
				switch self {
				case let Array(state):		return	state
				default:					return	nil
				}
			}
		}
		public var string:SwiftString? {
			get {
				switch self {
				case let String(state):		return	state
				default:					return	nil
				}
			}
		}
		public var number:Standard.RFC4627.Number? {
			get {
				switch self {
				case let Number(state):		return	state
				default:					return	nil
				}
			}
		}
		public var boolean:Bool? {
			get {
				switch self {
				case let Boolean(state):	return	state
				default:					return	nil
				}
			}
		}
		public var null:Bool {
			get {
				switch self {
				case let Null:				return	true
				default:					return	false
				}
			}
		}
	}
	
	///	Arbitrary precision number container.
	public enum Number : Equatable {
		case Integer(Int64)
		case Float(Double)
//		case Decimal(NSDecimalNumber)		//	Very large sized decimal number.
//		case Arbitrary(expression:String)	//	Arbitrary sized integer/real number expression.
		
		public var integer:Int64? {
			get {
				switch self {
				case let Integer(state):	return	state
				default:					return	nil
				}
			}
		}
		public var float:Double? {
			get {
				switch self {
				case let Float(state):		return	state
				default:					return	nil
				}
			}
		}
	}

}

public extension Standard.RFC4627.Value {
	public static func deserialise(data:NSData) -> Standard.JSON.Value? {
		var	e1:NSError?		=	nil
		let	o2:AnyObject?	=	NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &e1)
		
		assert(e1 == nil)
		if e1 != nil { return Error.trap() }
		if o2 == nil { return Error.trap() }
		
		let	o3	=	Converter.convertFromOBJ(o2!)
		return	o3
	}
	public static func serialise(value:Standard.JSON.Value) -> NSData? {
		let	o2:AnyObject	=	Converter.convertFromSwift(value)
		var	e1:NSError?		=	nil
		let	d3:NSData?		=	NSJSONSerialization.dataWithJSONObject(o2, options: NSJSONWritingOptions.PrettyPrinted, error: &e1)
		///	I don't think there's any reason to return `nil` from JSON serialisation, 
		///	but anyway, OBJC API is written in that way. I just follow it.
		if e1 != nil { return Error.trap() }
		if d3 == nil { return Error.trap() }
		return	d3!
	}
}

public func == (l:Standard.JSON.Value, r:Standard.JSON.Value) -> Bool {
	if l.null && r.null { return true }
	if l.boolean != nil && r.boolean != nil { return l.boolean! == r.boolean! }
	if l.number != nil && r.number != nil { return l.number! == r.number! }
	if l.string != nil && r.string != nil { return l.string! == r.string! }
	if l.array != nil && r.array != nil { return l.array! == r.array! }
	if l.object != nil && r.object != nil { return l.object! == r.object! }
	return	false
}
public func == (l:Standard.JSON.Number, r:Standard.JSON.Number) -> Bool {
	if l.integer != nil && r.integer != nil { return l.integer! == r.integer! }
	if l.float != nil && r.float != nil { return l.float! == r.float! }
	return	false
}





















///	Implicit serialisations.
public extension Standard.RFC4627 {
	
	///	Returns `nil` for any errors.
	///	See `serialise` function for type-mapping informations.
	public static func deserialise(data:NSData) -> Any? {
		///	Converting from `Value` tree never raise an error.
		///	Returning `nil` is a normal regular value for JSON null.
		func fromValue(v1:Value) -> Any? {
			func fromArray(a1:[Value]) -> [Any?] {
				var	a2	=	[] as [Any?]
				for m1 in a1 {
					let	m2	=	fromValue(m1)
					a2.append(m2)
				}
				return	a2
			}
			func fromObject(o1:[String:Value]) -> [String:Any?] {
				var	o2	=	[:] as [String:Any?]
				for (k1,v1) in o1 {
					let	v2	=	fromValue(v1)
					o2[k1]	=	v2
				}
				return	o2
			}
			
			switch v1 {
				case Value.Null:			return	nil
				case Value.Boolean(let v1):	return	v1
				case Value.Number(let v1):
					switch v1 {
						case Number.Integer(let v2):	return	v2
						case Number.Float(let v2):		return	v2
					}
				case Value.String(let v1):	return	v1
				case Value.Array(let v1):	return	fromArray(v1)
				case Value.Object(let v1):	return	fromObject(v1)
			}
		}
		
		let	v1	=	Value.deserialise(data)
		return	v1 == nil ? Error.trap() : fromValue(v1!)
	}
	
	///
	///	Type mappings:
	///
	///		JSON type			Swift type
	///		---------			----------
	///		null				nil*
	///		boolean				Bool
	///		number				Int64/Float64**
	///		string				String
	///		array				[Any?]***
	///		object				[String:Any?]***
	///
	///	*	Ultimate container type is `Any?`, and it will be treated as JSON null
	 ///	if the optional state is `nil`.
	///
	///	**	All other numeric typed are accepted for JSON number type when encoding,
	///		but they will become one of `Int64/Float64` types when decoded.
	///		`UInt64` is not accepted in current implementation due to precision limit.
	///
	///	***	Strongly typed homogeneous arrays are not supported. Because it needs tracking
	///		back of original type, but literally *infinite* number of original type can be
	///		exist. This cannot be supported until Swift to provide some generalised way to 
	///		access array elements regardless of element type.
	///
	public static func serialise(value:Any?) -> NSData? {

		func toValue(v0:Any?) -> Value? {
			func toArray(a1:[Any?]) -> Value? {
				var	a2	=	[] as [Value]
				for m1 in a1 {
					let	m2	=	toValue(m1)
					if m2 == nil { return Error.trap() }
					a2.append(m2!)
				}
				return	Value.Array(a2)
			}
			func toObject(o1:[String:Any?]) -> Value? {
				var	o2	=	[:] as [String:Value]
				for (k1, v1) in o1 {
					let	v2	=	toValue(v1)
					if v2 == nil { return Error.trap() }
					o2[k1]	=	v2!
				}
				return	Value.Object(o2)
			}

			if v0 == nil {
				return Value.Null
			} else {
				let	v1	=	v0!
				if v1 is Bool { return Value.Boolean(v1 as Bool) }
				
				if v1 is Int { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as Int))) }
				if v1 is Int8 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as Int8))) }
				if v1 is Int16 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as Int16))) }
				if v1 is Int32 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as Int32))) }
				if v1 is Int64 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as Int64))) }
				
				if v1 is UInt { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as UInt))) }
				if v1 is UInt8 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as UInt8))) }
				if v1 is UInt16 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as UInt16))) }
				if v1 is UInt32 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as UInt32))) }
//				if v1 is UInt64 { return Value.Number(Standard.RFC4627.Number.Integer(Int64(v1 as UInt64))) }
				
				if v1 is Float { return Value.Number(Standard.RFC4627.Number.Float(Float64(v1 as Float))) }
				if v1 is Float32 { return Value.Number(Standard.RFC4627.Number.Float(Float64(v1 as Float32))) }
				if v1 is Float64 { return Value.Number(Standard.RFC4627.Number.Float(Float64(v1 as Float64))) }
				
				if v1 is String { return Value.String(v1 as String) }
				if v1 is Array<Any?> { return toArray(v1 as [Any?]) }
				if v1 is Dictionary<String,Any?> { return toObject(v1 as [String:Any?]) }
		
				
				return	Error.trap("Unsupported type detected in value (\(v1)) while serialising an object tree into JSON.")
			}
		}
		
		let	v2	=	toValue(value)
		if let v3 = v2 {
			return	Value.serialise(v3)
		}
		return	Error.trap()
	}
}

















private struct Error {
	static func trap<T>(_ message:String? = nil) -> T? {
		///	Install debugger breakpoint here to stop at any returning-`nil`-by-an-error situation.
		#if DEBUG
			if message != nil {
				println("Trapped an error in `Standard.JSON` feature: " + message!)
			}
		#endif
		return	nil
	}
}

///	Converts JSON tree between Objective-C and Swift representations.
private struct Converter {
	typealias	JSON	=	Standard.JSON
	typealias	Value	=	JSON.Value
	
	///	Objective-C `nil` is not supported as an input.
	///	Use `NSNull` which is standard way to represent `nil`
	///	in data-structures in Cocoa.
	static func convertFromOBJ(v1:AnyObject) -> Value? {
		assert(v1 is NSObject)
		func convertArray(v1:NSArray) -> Value? {
			var	a2	=	[] as [Value]
			for m1 in v1 {
				///	Must be an OBJC type.
				if (m1 is NSObject) == false { return Error.trap() }
				
				let	m2	=	convertFromOBJ(m1 as NSObject)
				if m2 == nil { return Error.trap() }
				
				a2.append(m2!)
			}
			return	Value.Array(a2)
		}
		func convertObject(v1:NSDictionary) -> Value? {
			var	o2	=	[:] as [String:Value]
			for p1 in v1 {
				let	k1	=	p1.key as? String
				if k1 == nil { return Error.trap() }
				
				let	v2	=	convertFromOBJ(p1.value)
				if v2 == nil { return Error.trap() }
				
				o2[k1! as String]	=	v2!
			}
			return	Value.Object(o2)
		}
		
		if v1 is NSNull { return Value.Null }
		if v1 is NSNumber {
			let	v2	=	v1 as NSNumber
			///	`NSNumber` can be a `CFBoolean` exceptionally if it was created from a boolean value.
			if CFGetTypeID(v2) == CFBooleanGetTypeID() {
				let	v3	=	CFBooleanGetValue(v2) != 0
				return	Value.Boolean(v3)
			}
			if CFNumberIsFloatType(v2) != 0 {
				return	Value.Number(Standard.RFC4627.Number.Float(v2.doubleValue))
			} else {
				return	Value.Number(Standard.RFC4627.Number.Integer(v2.longLongValue))
			}
		}
		if v1 is NSString { return Value.String(v1 as NSString as String) }
		if v1 is NSArray { return convertArray(v1 as NSArray) }
		if v1 is NSDictionary { return convertObject(v1 as NSDictionary) }
		
		return	Error.trap("Unsupported type. Failed.")
	}
	static func convertFromSwift(v1:Value) -> AnyObject {
		func convertArray(a1:[Value]) -> NSArray {
			let	a2	=	NSMutableArray()
			for m1 in v1.array! {
				let	m2:AnyObject	=	convertFromSwift(m1)
				a2.addObject(m2)
			}
			return	a2
		}
		func convertObject(o1:[String:Value]) -> NSDictionary {
			let	o2	=	NSMutableDictionary()
			for (k1, v1) in o1 {
				let	k2				=	k1 as NSString
				let	v2:AnyObject	=	convertFromSwift(v1)
				o2.setObject(v2, forKey: k2)
			}
			return	o2
		}
		
		switch v1 {
		case let Value.Null:		return	NSNull()
		case let Value.Boolean(s1):	return	NSNumber(bool: s1)
		case let Value.Number(s1):
			switch s1 {
			case let Standard.JSON.Number.Integer(s2):	return	NSNumber(longLong: s2)
			case let Standard.JSON.Number.Float(s2):	return	NSNumber(double: s2)
			}
		case let Value.String(s1):	return	s1 as NSString
		case let Value.Array(s1):	return	convertArray(s1)
		case let Value.Object(s1):	return	convertObject(s1)
		}
	}
}


































































//private struct Parser {
//	
//}
//private struct Scanners {
//	struct StringLiteralScanner {
//		var	value:String?	=	""
//
//		func push(ch1:Character) {
//			if value == nil { return }
//			if value! == "" {
//				if ch1 != "\"" {
//					return	nil
//				}
//				
//				value!.append(ch1)
//			}
//		}
//		func scanUnescapedCharacter(ch1:Character) {
//			scan {
//				return	ch1
//			}
//		}
//		func scanQuotation(ch1:Character) {
//			scan({ return ch1 == "\"" ? ch1 : nil })
//		}
//		func scan(resolver:()->Character?) {
//			if value != nil {
//				if let v1 = resolver() {
//					value!.append(v1)
//					return
//				}
//			}
//			value	=	nil
//		}
//	}
//	static func tokenise(characters:String) -> [Token] {
//		
//	}
//}
//private struct Token {
//	let	data:String
//	let	capturing:Range<String.Index>
//	let	classification:Type
//	
//	var content:String {
//		get {
//			return	data[capturing]
//		}
//	}
//	
//	enum Type {
//		case Punctuation
//		case NumericLiteral
//		case StringLiteral
//	}
//}
//private struct Cursor {
//	let	dataSource:String
//	let	currentLocation:String.Index
//	
//	var dataAvailable:Bool {
//		get {
//			return	currentLocation < dataSource.endIndex
//		}
//	}
//	var currentCharacter:Character {
//		get {
//			assert(dataAvailable)
//			return	dataSource[currentLocation]
//		}
//	}
//	func stepping() -> Cursor {
//		assert(dataAvailable)
//		return	Cursor(dataSource: dataSource, currentLocation: currentLocation.successor())
//	}
//}
//



































///	MARK:
extension Standard.RFC4627 {
	struct Test {
		static func run() {
			func assert(c:@autoclosure()->Bool) {
				if c() == false {
					fatalError("Test assertion failure!")
				}
			}
			func tx(c:()->()) {
				c()
			}
			
			
			
			typealias	JSON	=	Standard.JSON
			
			
			tx {
				let	a1	=	"{ \"aaa\" : 123 }"
				let	a2	=	a1.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
				let	a3	=	JSON.Value.deserialise(a2)!
				
				let	a4	=	JSON.Value.Object([
					"aaa"	:	JSON.Value.Number(Standard.RFC4627.Number.Integer(123))
					])
				
				assert(a3 == a4)
			}
			
			tx {
				let	a1	=	[
					"aaa"	:	nil,
					"bbb"	:	true,
					"ccc"	:	123,
					"ddd"	:	456.789,
					"eee"	:	"Here b a dragon.",
					"fff"	:	["xxx", "yyy", "zzz"] as [Any?],
					"ggg"	:	[
						"f1"	:	"v1",
						"f2"	:	"v2",
						"f3"	:	"v3",
					] as [String:Any?],
				] as [String:Any?]
				
				println(a1["aaa"]!)
				let	v1	=	a1["aaa"]!
				assert(a1["aaa"]! == nil)
				
				let	a2	=	JSON.serialise(a1)!
				println(a2)
				
				let	a3	=	JSON.deserialise(a2)!
				println(a3)
				
				assert(a3 is [String:Any?])
			}
			
		}
	}
}


