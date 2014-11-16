//
//  AppDelegate.swift
//  TestApplication
//
//  Created by Hoon H. on 11/9/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Cocoa
import EonilCancellableBlockingIO





@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

	@IBOutlet weak var window: NSWindow!


	func applicationDidFinishLaunching(aNotification: NSNotification) {
		let	q1	=	HTTP.AtomicTransmission.Request(security: false, method: "GET", host: "apple.com", port: 80, path: "/", headers: [], body: NSData())
		let	t1	=	Trigger()
		let	a1	=	HTTP.transmit(q1, t1)
		println(a1)
	}

	func applicationWillTerminate(aNotification: NSNotification) {
		// Insert code here to tear down your application
	}


}

