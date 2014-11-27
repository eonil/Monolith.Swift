//
//  ViewController.swift
//  TestdriveApp
//
//  Created by Hoon H. on 11/28/14.
//
//

import UIKit
import EonilUIKitExtras

class ViewController: StaticTableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		table.appendSection()
		table.sections[0].appendRow()
		table.sections[0].appendRow()
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		let	s	=	StaticTableSection()
		s.appendRow()
		s.appendRow()
		s.appendRow()
		
		let	rs	=	s.rows
		s.deleteAllRows()
		
		table.sections[0].rows	=	rs
//		table.replaceSectionAtIndex(0, withSection: s, animation: UITableViewRowAnimation.Fade)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}

