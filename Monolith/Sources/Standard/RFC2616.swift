//
//  RFC2616.swift
//  Monolith
//
//  Created by Hoon H. on 10/20/14.
//
//

import Foundation

extension Standard {

	typealias	HTTP	=	RFC2616
	
	///	Defines HTTP/1.1 protocol.
	///	http://tools.ietf.org/html/rfc2616
	class RFC2616 {
		enum Method : String {
			case Options	=	"OPTIONS"
			case Get		=	"GET"
			case Head		=	"HEAD"
			case Post		=	"POST"
			case Delete		=	"DELETE"
			case Trace		=	"TRACE"
			case Connect	=	"CONNECT"
		}	
	}
}










extension Standard.RFC2616 {
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
			
						
		}
	}
}








