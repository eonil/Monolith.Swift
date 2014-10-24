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
		Tests.runAll()
		return true
	}
}



