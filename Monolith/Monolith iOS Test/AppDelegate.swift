//
//  AppDelegate.swift
//  Monolith iOS Test
//
//  Created by Hoon H. on 10/19/14.
//
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		Standard.RFC1808.Test.run()
		Standard.RFC3339.Test.run()
		Standard.RFC2616.Test.run()
		Standard.RFC4627.Test.run()
		println("All test OK.")
		return true
	}
}



