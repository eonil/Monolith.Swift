//
//  Anchors.swift
//  CratesIOViewer
//
//  Created by Hoon H. on 11/23/14.
//
//

import Foundation

#if os(iOS)
import UIKit
#endif

#if os(OSX)
import AppKit
#endif





public struct Anchor {
	
	#if	os(iOS)
	public typealias	Priority	=	UILayoutPriority
	public typealias	View		=	UIView
	#endif
	
	#if	os(OSX)
	public typealias	Priority	=	NSLayoutPriority
	public typealias	View		=	NSView
	#endif


	private var	view:View
	private var	x:NSLayoutAttribute
	private var	y:NSLayoutAttribute
	
	var dimensions:Int {
		get {
			let	c1	=	x == NA ? 0 : 1
			let c2	=	y == NA ? 0 : 1
			return	c1 + c2
		}
	}
	
	///	Returns an anchor object if for same location of the view.
	///	For example, if this anchor was obtained from `leftTop`, 
	///	this returns `leftTop` of the supplied view.
	func forView(v:View) -> Anchor {
		var	a1	=	self
		a1.view	=	v
		return	a1
	}
}



//private let	UILayoutPriorityRequired			=	1000
//private let	UILayoutPriorityDefaultHigh			=	750
//private let	UILayoutPriorityFittingSizeLevel	=	50
private let	REQUIRED	=	1000	as Float
private let	HIGH		=	750		as Float
private	let	FITTING		=	50		as Float




public extension Anchor.View {
	public func addConstraintsWithLayoutAnchoring(a:[AnchoringEqualityExpression]) {
		addConstraintsWithLayoutAnchoring(a, priority: REQUIRED)
	}
	///	Returns array of `NSLayoutConstraint` which are added to the view.
	public func addConstraintsWithLayoutAnchoring(a:[AnchoringEqualityExpression], priority:Anchor.Priority) -> [NSLayoutConstraint] {
		let	a1	=	a.map({$0.constraints})
		let	a2	=	a1.reduce([] as [NSLayoutConstraint], combine: { u, n in return u + n })
		a2.map({$0.priority = priority})
		addConstraints(a2)
		return	a2
	}
}






///	1D anchors.
public extension Anchor.View {
	public var	centerXAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.CenterX, y: NA)
		}
	}
	
	public var	centerYAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NA, y: NSLayoutAttribute.CenterY)
		}
	}
	public var	leftAnchor:Anchor {
		get {
			return	Anchor(view: self, x: LEFT, y: NA)
		}
	}
	public var	rightAnchor:Anchor {
		get {
			return	Anchor(view: self, x: RIGHT, y: NA)
		}
	}
	public var	topAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NA, y: TOP)
		}
	}
	public var	bottomAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NA, y: BOTTOM)
		}
	}
	public var	baselineAnchor:Anchor {
		get {
			return	Anchor(view: self, x: BASELINE, y: NA)
		}
	}
}




///	2D anchors.
public extension Anchor.View {
	public var	centerAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.CenterX, y: NSLayoutAttribute.CenterY)
		}
	}
	public var leftTopAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Left, y: NSLayoutAttribute.Top)
		}
	}
	
	public var leftCenterAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Left, y: NSLayoutAttribute.CenterY)
		}
	}
	public var leftBottomAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Left, y: NSLayoutAttribute.Bottom)
		}
	}
	
	public var centerTopAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.CenterX, y: NSLayoutAttribute.Top)
		}
	}
	public var centerBottomAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.CenterX, y: NSLayoutAttribute.Bottom)
		}
	}
	
	public var rightTopAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Right, y: NSLayoutAttribute.Top)
		}
	}
	public var rightCenterAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Right, y: NSLayoutAttribute.CenterY)
		}
	}
	
	public var rightBottomAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Right, y: NSLayoutAttribute.Bottom)
		}
	}
	
	public var leftBaselineAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Left, y: NSLayoutAttribute.Baseline)
		}
	}
	public var rightBaselineAnchor:Anchor {
		get {
			return	Anchor(view: self, x: NSLayoutAttribute.Right, y: NSLayoutAttribute.Baseline)
		}
	}
}











public struct AnchoringEqualityExpression {
	private let	left:Anchor
	private let right:Anchor
	private let	relation:NSLayoutRelation
	private let	displacement:CGSize
	
	public var constraints:[NSLayoutConstraint] {
		get {
			precondition((left.x == NA && right.x == NA) || (left.x != NA && right.x != NA), "You cannot connect anchors with `~Only` into different axis.")
			precondition((left.y == NA && right.y == NA) || (left.y != NA && right.y != NA), "You cannot connect anchors with `~Only` into different axis.")
			
			var	a1	=	[] as [NSLayoutConstraint]
			if left.x != NA && right.x != NA {
				let	c1	=	NSLayoutConstraint(item: left.view, attribute: left.x, relatedBy: relation, toItem: right.view, attribute: right.x, multiplier: 1, constant: displacement.width)
				a1.append(c1)
			}
			if left.y != NA && right.y != NA {
				let	c1	=	NSLayoutConstraint(item: left.view, attribute: left.y, relatedBy: relation, toItem: right.view, attribute: right.y, multiplier: 1, constant: displacement.height)
				a1.append(c1)
			}
			return	a1
		}
	}
}
public struct AnchoringDisplacementExpression {
	private let	anchor:Anchor
	private let	displacement:CGSize
}

public func == (left:Anchor, right:Anchor) -> AnchoringEqualityExpression {
	return	left == right + CGSize.zeroSize
}
public func == (left:Anchor, right:AnchoringDisplacementExpression) -> AnchoringEqualityExpression {
	return	AnchoringEqualityExpression(left: left, right: right.anchor, relation: NSLayoutRelation.Equal, displacement: right.displacement)
}

public func >= (left:Anchor, right:Anchor) -> AnchoringEqualityExpression {
	return	left >= right + CGSize.zeroSize
}
public func >= (left:Anchor, right:AnchoringDisplacementExpression) -> AnchoringEqualityExpression {
	return	AnchoringEqualityExpression(left: left, right: right.anchor, relation: NSLayoutRelation.GreaterThanOrEqual, displacement: right.displacement)
}

public func <= (left:Anchor, right:Anchor) -> AnchoringEqualityExpression {
	return	left <= right + CGSize.zeroSize
}
public func <= (left:Anchor, right:AnchoringDisplacementExpression) -> AnchoringEqualityExpression {
	return	AnchoringEqualityExpression(left: left, right: right.anchor, relation: NSLayoutRelation.LessThanOrEqual, displacement: right.displacement)
}

public func + (left:Anchor, right:CGSize) -> AnchoringDisplacementExpression {
	return	AnchoringDisplacementExpression(anchor: left, displacement: right)
}










private let			NA			=	NSLayoutAttribute.NotAnAttribute
private let			LEFT		=	NSLayoutAttribute.Left
private let			RIGHT		=	NSLayoutAttribute.Right
private let			TOP			=	NSLayoutAttribute.Top
private let			BOTTOM		=	NSLayoutAttribute.Bottom
private let			BASELINE	=	NSLayoutAttribute.Baseline

private typealias	ATTR		=	NSLayoutAttribute










