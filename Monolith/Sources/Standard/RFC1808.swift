//
//  RFC1808.swift
//  Monolith
//
//  Created by Hoon H. on 10/20/14.
//
//

import Foundation

public extension Standard {
	
	///	http://tools.ietf.org/html/rfc1808
	///	Defines URL features.
	///	This just complements `NSURL`, and does not
	///	try to cover the full specification.
	public class RFC1808 {
		
		public struct Query {
			public static func encode(parameters:[String:String]) -> String? {
				var	r1	=	[] as [(String,String)]
				for (k, v) in parameters {
					r1	+=	[(k, v)]
				}
				return	encode(r1)
			}
			///	Returning string is URL-encoded string.
			public static func encode(parameters:[(String, String)]) -> String {
				let	ue		=	Utility.URLEncode
				let	nvs1	=	parameters.map({ (n, v) in return ue(n) + "=" + ue(v) }) as [String]
				let	s1		=	join("&", nvs1)
				return	s1
			}
			///	Returns `nil` if any error has been found.
			///
			///	Note: input expression must be URL-encoded string.
			public static func decode(expression:String) -> [(String, String)]? {
				var	r1	=	[] as [(String,String)]
				let	ps1	=	split(expression, { (c:Character) -> Bool in return c == "&" }, maxSplit: Int.max, allowEmptySlices: true)
				for p1 in ps1 {
					let	ns1	=	split(p1, { (c:Character) -> Bool in return c == "=" }, maxSplit: Int.max, allowEmptySlices: true)
					if ns1.count != 2 {
						return	nil
					}
					let	n1	=	Utility.URLDecode(ns1[0])
					let	v1	=	Utility.URLDecode(ns1[1])
					
					if n1 == nil { return nil }
					if v1 == nil { return nil }
					
					r1		+=	[(n1!, v1!)]
				}
				return	r1
			}
			
			private struct Utility {
				static func URLEncode(s1:String) -> String {
					let	s2	=	____URLEncode(s1)		///	Fallback to OBJC due to SDK bug that disables using of a `CFStringEncoding` constants.
					return	s2 as NSString as String	///	Must be succeeded always.
				}
				static func URLDecode(s1:String) -> String? {
					return	s1.stringByRemovingPercentEncoding
				}
			}
		}

	}
}

































extension Standard.RFC1808 {
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
			
			///	Happy cases.
			tx {
				tx {
					let	sample1	=	[("aaa", "bbb"), ("ccc", "ddd")]
					let	result1	=	Query.encode(sample1)
					assert(result1 == "aaa=bbb&ccc=ddd")
					
					let	result2	=	Query.decode(result1)
					assert(result2 != nil)
					assert(result2!.count == 2)
					assert(result2![0].0 == "aaa")
					assert(result2![0].1 == "bbb")
					assert(result2![1].0 == "ccc")
					assert(result2![1].1 == "ddd")
				}
				tx {
					let	sample1	=	[("aaa", ""), ("", "ddd")]
					let	result1	=	Query.encode(sample1)
					assert(result1 == "aaa=&=ddd")
					
					let	result2	=	Query.decode(result1)
					assert(result2 != nil)
					assert(result2!.count == 2)
					assert(result2![0].0 == "aaa")
					assert(result2![0].1 == "")
					assert(result2![1].0 == "")
					assert(result2![1].1 == "ddd")
				}
				tx {
					let	sample1	=	[("?&=", "aaa"), ("bbb", "?&=")]
					let	result1	=	Query.encode(sample1)
					assert(result1 == "%3F%26%3D=aaa&bbb=%3F%26%3D")
					
					let	result2	=	Query.decode(result1)
					assert(result2 != nil)
					assert(result2!.count == 2)
					assert(result2![0].0 == "?&=")
					assert(result2![0].1 == "aaa")
					assert(result2![1].0 == "bbb")
					assert(result2![1].1 == "?&=")
				}
			}
			
			
			///	Evil cases.
			tx {
			}
			
		}
	}
}


























///	MARK:
///	Move to `RFC1808+RFC4627.swift` when compiler bug to be fixed.

public extension Standard.RFC1808.Query {
	///	Supports only string -> string flat JSON object.
	public static func encode(parameters:Standard.JSON.Object) -> String? {
		var	ps2	=	[:] as [String:String]
		for p1 in parameters {
			if p1.1.string == nil {
				return	Error.trap("Input string contains non-strig (possibly complex) value, and it cannot be used to form a query-string.")
			}
			ps2[p1.0]	=	p1.1.string!
		}
		return	encode(ps2)
	}
}
