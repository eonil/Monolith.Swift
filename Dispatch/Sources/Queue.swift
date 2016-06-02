//
//  Queue.swift
//  EonilDispatch
//
//  Created by Hoon H. on 11/12/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation

public class Queue {
	let	rawQueue:dispatch_queue_t
	
	
	init(_ rawQueue:dispatch_queue_t) {
		self.rawQueue	=	rawQueue
	}
	public init(label:String) {
		rawQueue	=	dispatch_queue_create((label as NSString).UTF8String, nil)
	}
	
	@available(iOS,introduced=4.3)
	@available(OSX,introduced=10.7)
	public init(label:String, attribute:Attribute) {
		rawQueue	=	dispatch_queue_create((label as NSString).UTF8String, attribute.mapToObjC())
	}
	
	
	@available(iOS,introduced=4.3)
	@available(OSX,introduced=10.7)
	public enum Attribute {
		case Serial
		case Concurrent
		
		func mapToObjC() -> dispatch_queue_attr_t! {
			switch self {
				case .Serial:		return	DISPATCH_QUEUE_SERIAL
				case .Concurrent:	return	DISPATCH_QUEUE_CONCURRENT
			}
		}
	}
	
	
	public typealias	Priority		=	QueuePriority
	
	public class func global(identifier:QualityOfServiceClass) -> Queue {
		return	Queue(dispatch_get_global_queue(identifier.mapToObjC(), 0))
	}
	public class func global(identifier:Priority) -> Queue {
		return	Queue(dispatch_get_global_queue(identifier.mapToObjC(), 0))
	}
	public class var main:Queue {
		get {
			return	Queue(dispatch_get_main_queue())
		}
	}
}

public enum QualityOfServiceClass {
	case UserInteractive
	case UserInitiated
	case Utility
	case Background
	
	func mapToObjC() -> qos_class_t {
		switch self {
		case .UserInteractive:	return	QOS_CLASS_USER_INTERACTIVE
		case .UserInitiated:	return	QOS_CLASS_USER_INITIATED
		case .Utility:			return	QOS_CLASS_UTILITY
		case .Background:		return	QOS_CLASS_BACKGROUND
		}
	}
}

//#define DISPATCH_QUEUE_PRIORITY_HIGH         2
//#define DISPATCH_QUEUE_PRIORITY_DEFAULT      0
//#define DISPATCH_QUEUE_PRIORITY_LOW          (-2)
//#define DISPATCH_QUEUE_PRIORITY_BACKGROUND   INT16_MIN
public enum QueuePriority {
	case High
	case Default
	case Low
	case Background
	
	func mapToObjC() -> Int {
		switch self {
			case .High:			return	DISPATCH_QUEUE_PRIORITY_HIGH
			case .Default:		return	DISPATCH_QUEUE_PRIORITY_DEFAULT
			case .Low:			return	DISPATCH_QUEUE_PRIORITY_LOW
			case .Background:	return	DISPATCH_QUEUE_PRIORITY_BACKGROUND
		}
	}
}







