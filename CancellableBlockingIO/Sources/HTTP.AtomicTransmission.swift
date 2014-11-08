//
//  HTTPAtomicDataTransmission.swift
//  EonilBlockingAsynchronousIO
//
//  Created by Hoon H. on 11/7/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

extension HTTP {
	public struct AtomicTransmission {
		public typealias	Error	=	DebugPrintable
		
		public typealias Header	=	(
			name:String,
			value:String
		)
		
		public struct Request {
			var	security:Bool
			var	method:String
			var	host:String
			var	port:Int
			var	path:String					///<	Will be encoded using RFC 3986. So do not passed encoded one.
			var	headers:[Header]
			var	body:NSData
		}
		public struct Response {
			var	status:Int
			var	headers:[Header]
			var	body:NSData
		}
		
//		public enum Initiate {
//			case Launch(Request)
//		}
		public enum Complete {
			case Cancel					///<	Operation stopped actively by programmer command.
			case Abort(Error)			///<	Operation stopped passively without programmer command.
			case Done(Response)			///<	Operation normally finished.
		}
	}
}

public extension HTTP.AtomicTransmission {
	
	///	Uploads and downloads all data at once.
	///	This blocks the caller until the operation finishes.
	public static func execute(parameters:Request, cancellation:Trigger) -> Complete {
		if cancellation.state {
			return	Complete.Cancel
		}
		
		////
		
		let	addr1	=	NSURL(scheme: (parameters.security ? "https" : "http") as NSString, host: parameters.host as NSString, path: parameters.path as NSString)!
		let	reqe1	=	NSMutableURLRequest(URL: addr1, cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 15)
		reqe1.HTTPMethod	=	parameters.method
		for h1 in parameters.headers {
			reqe1.addValue(h1.value, forHTTPHeaderField: h1.name)
		}
		reqe1.HTTPBody		=	parameters.body
		
		var	tran1	=	Transfer<Response>()
		let	task1	=	NSURLSession.sharedSession().dataTaskWithRequest(reqe1, completionHandler: { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
			let	r1	=	response as NSHTTPURLResponse
			var	hs1	=	[] as [Header]
			for h1 in r1.allHeaderFields {
				hs1.append((name: h1.0 as String, value: h1.1 as String))
			}
			let	r2	=	Response(status: r1.statusCode, headers: hs1, body: data!)
			tran1.signal(r2)
		})
		
		task1.resume()
		return	Complete.Done(tran1.wait())
	}
	
}