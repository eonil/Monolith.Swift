//
//  ViewController.swift
//  TestdriveApp
//
//  Created by Hoon H. on 11/28/14.
//
//

import UIKit
import EonilUIKitExtras

func makeLabelForTest() -> UILabel {
	let	v	=	UILabel(translatesAutoresizingMaskIntoConstraints: false)
	v.backgroundColor	=	UIColor.redColor()
	v.addConstraintsWithLayoutAnchoring([
		v.bottomAnchor	==	v.topAnchor + CGSize(width: 0, height: 100)
		], priority: 750)
//	v.invalidateIntrinsicContentSize()
	return	v
}
func makeViewForTest() -> UIView {
	let	v	=	UISegmentedControl(translatesAutoresizingMaskIntoConstraints: false)
	v.insertSegmentWithTitle("AAAA", atIndex: 0, animated: false)
	v.insertSegmentWithTitle("AAAA", atIndex: 0, animated: false)
	v.insertSegmentWithTitle("AAAA", atIndex: 0, animated: false)
	return	v
}

class ViewController: StaticTableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		
		table.appendSection().header	=	makeLabelForTest()
		table.sections.last!.appendRow()
		table.sections.last!.appendRow()
		table.sections.last!.appendRow()
//		self.tableView.layoutIfNeeded()
//		self.tableView.updateConstraints()
		
//		table.sections[0].appendRow()
//		table.sections[0].appendRow()
//		
//		
//		let	s	=	StaticTableSection()
//		s.appendRow()
//		s.appendRow()
//		s.appendRow()
//		
//		s.header	=	makeLabelForTest()
//		
//		table.appendSection(s)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		table.appendSection().header	=	makeLabelForTest()
		table.sections.last!.appendRow()
		table.sections.last!.appendRow()
		table.sections.last!.appendRow()
		
//		tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: UITableViewRowAnimation.None)
//		tableView.reloadData()
//		UIView.setAnimationsEnabled(true)
		
	}
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
//		assert(table.sections[1].header!.superview !== nil)
//		self.view.setNeedsDisplay()
//		self.view.layoutIfNeeded()
//		self.view.invalidateIntrinsicContentSize()
////		assert(v.superview === tableView)
		
		
		
//		let	rs	=	s.rows
//		s.deleteAllRows()
//		
//		
//		table.sections[0].rows	=	rs
////		table.replaceSectionAtIndex(0, withSection: s, animation: UITableViewRowAnimation.Fade)
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}


}





