//
//  AppDelegate.swift
//  Tester
//
//  Created by Hoon H. on 11/4/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import	Cocoa
import	EonilPipe







@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!
	
	///	Example 2.
	///	Shows various asynchronous filter composition.
	class Example2 {
		class func NOOP() {
		}
		var	c1	=	0
		var	cancelTest	=	Example2.NOOP as Cancel
		
		func checkup() {
			if c1 == 20 {
				cancelTest()
			}
		}
		
		func run() {
			let	f1	=	ConstantTimeWaitTask<String>(0.01)
			let	f2	=	Step { (s:String)->String in println("PASSING: \(s) ~ \(++self.c1)"); return s }
			let f2b	=	Step { (s:String)->String in self.checkup(); return s }
			let	f3	=	f1 ~~> f2 ~~> f2b
			
			var	f4	=	nil as TaskOf<String,String>?
			let	f5	=	DynamicTask { self.c1 < 100 ? f4! : task(Step{$0}) }
			let	f6	=	f3 ~~> f5
			f4		=	task(f6)
			
			self.cancelTest	=	f6.dispatch("Hello!") { String->() in println("DONE!") }
		}

	}
	
	
	
	
	
	func applicationDidFinishLaunching(aNotification: NSNotification) {
		func example1() {
			let	f1	=	ValueEmitterTask("AAA")
			let	f2	=	Step { TimeSignal(time: 1, value: $0 + " A") }
			let	f3	=	Step { TimeSignal(time: 2, value: $0 + " B") }
			let	f4	=	Step { TimeSignal(time: 3, value: $0 + " C") }
			let	f5	=	ParametricTimeWaitTask<String>()
			let	f6	=	Step<String,()> { $0 >>> println }
			
			let	f8	=	f1 >>> [
				f2 >>> f5 >>> f6,
				f3 >>> f5 >>> f6,
				f4 >>> f5 >>> f6,
			]
			
//			let	f9	=	f8 >>> nil
//			let	c1	=	f9.dispatch()
			
			let	f9	=	f8
			let	c1	=	f9.dispatch((), {})
		}
		example1()
	}

	func applicationWillTerminate(aNotification: NSNotification) {
	}


}

