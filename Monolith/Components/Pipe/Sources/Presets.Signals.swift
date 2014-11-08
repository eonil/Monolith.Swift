//
//  Presets.Signals.swift
//  Pipe
//
//  Created by Hoon H. on 11/8/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation


public protocol ValueSignal {
	typealias	T
	var value:T? { get }
}
public protocol CancellableSignal {
	var cancel:Bool { get }
}



public enum Cancallable<T> : CancellableSignal, ValueSignal {
	case Value(T)
	case Cancel
	
	public var value:T? {
		get {
			switch self {
			case let Value(s):	return	s
			default:			return	nil
			}
		}
	}
	
	public var cancel:Bool {
		get {
			switch self {
			case Cancel:	return	true
			default:		return	false
			}
		}
	}
}

public enum WaitSignal<T> : CancellableSignal {
	case Time(T)
	case Cancel
	
	public var cancel:Bool {
		get {
			switch self {
			case Cancel:	return	true
			default:		return	false
			}
		}
	}
}

