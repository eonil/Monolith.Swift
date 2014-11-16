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
			public var	security:Bool
			public var	method:String
			public var	host:String
			public var	port:Int
			public var	path:String					///<	Will be encoded using RFC 3986. So do not passed encoded one.
			public var	headers:[Header]
			public var	body:NSData?
			
			public init(security:Bool, method:String, host:String, port:Int, path:String, headers:[HTTP.AtomicTransmission.Header], body:NSData?) {
				self.security	=	security
				self.method		=	method
				self.host		=	host
				self.port		=	port
				self.path		=	path
				self.headers	=	headers
				self.body		=	body
			}
		}
		public struct Response {
			public var	status:Int
			public var	headers:[Header]
			
			///	Body can be missing if the request does not need to provide 
			///	output as a successful request. `nil` on this parameter does 
			///	not mean it request failed. If you got a this object, then
			///	that means request itself finished successfully.
			public var	body:NSData?
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

public extension HTTP.AtomicTransmission.Request {
}

extension HTTP.AtomicTransmission.Request: Printable {
	public var description:String {
		get {
			return	"Request(securit: \(security), method: \(method), host: \(host), port: \(port), path: \(path), headers: \(headers), body: \(body?.length) bytes)"
		}
	}
}

extension HTTP.AtomicTransmission.Response: Printable {
	public var description:String {
		get {
			return	"Response(status: \(status), headers: \(headers), body: \(body?.length) bytes)"
		}
	}
}

extension HTTP.AtomicTransmission.Complete: Printable {
	public var description:String {
		get {
			switch self {
			case .Cancel:		return	"Cancel"
			case .Abort(let s):	return	"Abort(\(s))"
			case .Done(let s):	return	"Done(\(s))"
			}
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