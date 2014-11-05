//
//  Pipe.HTTP.swift
//  Monolith
//
//  Created by Hoon H. on 11/5/14.
//
//

import Foundation
import EonilPipe

extension Pipe {
	
	///	Task for `NSURLSessionDataTask`.
	///	Send and recieve small amount of data at once.
	public struct HTTPAtomicTranssmissionTask : Task {
		let	cachePolicy:NSURLRequestCachePolicy
		let	timeoutInterval:NSTimeInterval
		
		public init(cachePolicy:NSURLRequestCachePolicy, timeoutInterval:NSTimeInterval) {
			self.cachePolicy		=	cachePolicy
			self.timeoutInterval	=	timeoutInterval
		}
		
		public func dispatch(signal: Incoming, _ observer: Outgoing -> ()) -> Cancel {
			let	ErrorDomain	=	"HTTPAtomicTransmissionTask"
			
			switch signal {
			case .Run(parameters: let ps1):
				let	u1	=	NSURL(scheme: ps1.security ? "https" : "http", host: ps1.host, path: ps1.path)!
				let	r1	=	NSMutableURLRequest(URL: u1, cachePolicy: cachePolicy, timeoutInterval: timeoutInterval)
				r1.HTTPMethod	=	ps1.method
				let	t1	=	NSURLSession.sharedSession().dataTaskWithRequest(r1) { (data:NSData!, response:NSURLResponse!, error:NSError!) -> Void in
					if let e1 = error {
						observer(HTTPAtomicTranssmissionTask.Outgoing.Unavailable(e1))
						return
					}
					if response == nil {
						observer(HTTPAtomicTranssmissionTask.Outgoing.Unavailable(NSError(domain: ErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "There's no error, but also no response. HTTP(S) transmission failed."])))
						return
					}
					if data == nil {
						observer(HTTPAtomicTranssmissionTask.Outgoing.Unavailable(NSError(domain: ErrorDomain, code: 0, userInfo: [NSLocalizedDescriptionKey: "There's no error, but a response. Anyway data is provided as `nil`, so it is regarded as failure by an unknown error. HTTP(S) transmission failed."])))
						return
					}
					
					let	r2	=	response! as NSHTTPURLResponse
					let	hs1	=	collectHeaders(r2)
					let	r3	=	Outgoing.Response(status: r2.statusCode, headers: hs1, body: data)
					observer(HTTPAtomicTranssmissionTask.Outgoing.Available(r3))
				}
				
				t1.resume()
				return	{
					t1.cancel()
					observer(HTTPAtomicTranssmissionTask.Outgoing.Cancel)
				}
			}
		}
		
		public enum Incoming {
			case Run(parameters:Request)
			
			public struct Request {
				var	security:Bool
				var	method:String
				var	host:String
				var	port:Int
				var	path:String					///<	Will be encoded using RFC 3986. So do not passed encoded one.
				var	headers:[Header]
				var	body:NSData
			}
		}
		
		public enum Outgoing {
			
			///	Transmission just started and don't know yet the result.
			case Unknown
			
			///	Operation cancelled by calling the cance function.
			case Cancel
			
			///	Transmission successful. There's a response from the server.
			///	Take care that even `404` error from the server is regarded
			///	as success because it's also a response.
			case Available(Response)
			
			///
			case Unavailable(NSError)
			
			public struct Response {
				var	status:Int
				var	headers:[Header]
				var	body:NSData
			}
		}
		
		public typealias	Header	=	(name:String, value:String)
	}
	
	
	
	
	
	
	
	
	///	Task for `NSURLSessionDownloadTask`.
	///	Redirection will be handled automatically.
	public struct HTTPProgressiveDownloadTask : Task {
		public typealias	AuthenticationResolver	=	NSURLAuthenticationChallenge->(NSURLSessionAuthChallengeDisposition,NSURLCredential)
		
		///	Set an ID to be used for a parameter of `NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier()` method call.
		public let	backgroundOperationID:String
		///	Will be used for any situation which requires authentication.
		public let	authenticationResolver:AuthenticationResolver?
		
		public init(backgroundOperationID:String, authenticationResolver:AuthenticationResolver?) {
			self.backgroundOperationID	=	backgroundOperationID
			self.authenticationResolver	=	authenticationResolver
		}
		
		public func dispatch(signal: RequestSignal, _ observer: ResponseSignal -> ()) -> Cancel {
			
			
			struct GlobalQueue {
				static let	theQueue	=	NSOperationQueue()
			}
			
			final class Controller: NSObject, NSURLSessionDownloadDelegate {
				let	ErrorDomain	=	"HTTPProgressiveDownloadTask"
				let	observer:ResponseSignal->()
				let	authenticationResolver:AuthenticationResolver?
				
				init(observer:ResponseSignal->(), authenticationResolver:AuthenticationResolver?) {
					self.observer				=	observer
					self.authenticationResolver	=	authenticationResolver
				}
				deinit {
					System.Debug.log("A pipe task (\(self)) deinitialised.")
				}
				private func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didResumeAtOffset fileOffset: Int64, expectedTotalBytes: Int64) {
					let	r1	=	Range<Int64>(start: fileOffset, end: fileOffset)
					let	r2	=	expectedTotalBytes == NSURLSessionTransferSizeUnknown ? nil : Range<Int64>(start: 0, end: expectedTotalBytes) as Range<Int64>?
					observer(ResponseSignal.Progress(range: r1, total: r2))
					session.invalidateAndCancel()
				}
				private func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
					assert(totalBytesWritten >= bytesWritten)
					let	r1	=	Range<Int64>(start: totalBytesWritten - bytesWritten, end: totalBytesWritten)
					let	r2	=	totalBytesExpectedToWrite == NSURLSessionTransferSizeUnknown ? nil : Range<Int64>(start: 0, end: totalBytesExpectedToWrite) as Range<Int64>?
					observer(ResponseSignal.Progress(range: r1, total: r2))
				}
				private func URLSession(session: NSURLSession, downloadTask: NSURLSessionDownloadTask, didFinishDownloadingToURL location: NSURL) {
					observer(ResponseSignal.Available(file: location))
					session.invalidateAndCancel()
				}
				private func URLSession(session: NSURLSession, task: NSURLSessionTask, didCompleteWithError error: NSError?) {
					if let e2 = error {
						observer(HTTPProgressiveDownloadTask.ResponseSignal.Unavailable(error: e2))
					}
					session.invalidateAndCancel()
				}
				private func URLSession(session: NSURLSession, task: NSURLSessionTask, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
					assert(authenticationResolver != nil)
					if let a1 = authenticationResolver {
						let	(c1,c2)	=	a1(challenge)
						completionHandler(c1, c2)
					} else {
						session.invalidateAndCancel()
						let	info	=	[
							NSLocalizedDescriptionKey:	"This session requires authentication, but no resolver has been provided."
						] as [NSObject:AnyObject]
						let	err2	=	NSError(domain: ErrorDomain, code: 0, userInfo: [:])
						observer(HTTPProgressiveDownloadTask.ResponseSignal.Unavailable(error: err2))
					}
				}
//				private func URLSession(session: NSURLSession, task: NSURLSessionTask, didSendBodyData bytesSent: Int64, totalBytesSent: Int64, totalBytesExpectedToSend: Int64) {
//	
//				}
//				private func URLSession(session: NSURLSession, task: NSURLSessionTask, needNewBodyStream completionHandler: (NSInputStream!) -> Void) {
//	
//				}
//				private func URLSession(session: NSURLSession, task: NSURLSessionTask, willPerformHTTPRedirection response: NSHTTPURLResponse, newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void) {
//	
//				}
//				private func URLSession(session: NSURLSession, didBecomeInvalidWithError error: NSError?) {
//	
//				}
//				private func URLSession(session: NSURLSession, didReceiveChallenge challenge: NSURLAuthenticationChallenge, completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void) {
//	
//				}
			}
			
			let	conf1	=	NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier(backgroundOperationID)
			let	queue1	=	GlobalQueue.theQueue
			
			////
			
			let	dele1	=	Controller(observer: observer, authenticationResolver: authenticationResolver)
			let	sess1	=	NSURLSession(configuration: conf1, delegate: dele1, delegateQueue: queue1)
			
			func makeRawTask() -> NSURLSessionDownloadTask {
				switch signal {
				case .Launch(address: let a1):
					return	sess1.downloadTaskWithURL(a1, completionHandler: nil)
				case .Resume(continuation: let c1):
					return	sess1.downloadTaskWithResumeData(c1, completionHandler: nil)
				}
			}
			
			let	task	=	makeRawTask()
			let	cancel	=	{
				task.cancelByProducingResumeData { (c1:NSData!) -> Void in
					sess1.invalidateAndCancel()
					observer(ResponseSignal.Cancel(continuation: c1))
				}
				} as Cancel
			
			task.resume()
			return	cancel
		}
		
		public enum RequestSignal {
			case Launch(address:NSURL)
			case Resume(continuation:NSData)
		}
		
		public enum ResponseSignal {
//			case Authenticate(provide:(NSURLCredential)->())
			
			///	A part of data has been downloaded and written to disk.
			case Progress(range:Range<Int64>, total:Range<Int64>?)
			
			///	Operation cancelled by calling the cancel function. You can continue downloading
			///	using the continuation information if one is available.
			case Cancel(continuation:NSData?)
			
			///	Finished downloading of whole file. You can access the downloaded file at the URL.
			case Available(file:NSURL)
			
			///	Downloading failed.
			case Unavailable(error:NSError)
		}
	}
	
	
	
	
	

}


extension Pipe.HTTPProgressiveDownloadTask.ResponseSignal: Printable {
	public var description:String {
		get {
			switch self {
			case .Available(file: let f1):					return	"Available(\(f1))"
			case .Unavailable(error: let e1):				return	"Unavailable(\(e1))"
			case .Cancel(continuation: let c1):				return	"Cancel(\(c1))"
			case .Progress(range: let r1, total: let r2):	return	"Progress(range: \(r1), total: \(r2)"
			}
		}
	}
}













private typealias	Header	=	(name:String, value:String)

private func collectHeaders(r1:NSHTTPURLResponse) -> [Header] {
	var	a1	=	[] as [Header]
	for (k,v) in r1.allHeaderFields {
		a1.append((k as NSString as String, v as NSString as String))
	}
	return	a1
}
	