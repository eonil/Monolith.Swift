//
//  LayoutConstraint.swift
//  WeatherTable
//
//  Created by Hoon H. on 11/18/14.
//
//

import Foundation
import UIKit





public struct LayoutExpression {
	public let	argument:LayoutArgument
	public let	multiplier:CGFloat
	public let	constant:CGFloat
}

public typealias	LayoutArgument	=	(view: UIView, attribute:NSLayoutAttribute)

public let	width		=	NSLayoutAttribute.Width
public let	height		=	NSLayoutAttribute.Height
public let	centerX		=	NSLayoutAttribute.CenterX
public let	centerY		=	NSLayoutAttribute.CenterY

public let	left		=	NSLayoutAttribute.Left
public let	right		=	NSLayoutAttribute.Right
public let	top			=	NSLayoutAttribute.Top
public let	bottom		=	NSLayoutAttribute.Bottom

public let	baseline	=	NSLayoutAttribute.Baseline




infix operator .. {
	precedence 255			///	Precedence may be changed later.
}

infix operator ~~ {
	precedence 1			///	Precedence may be changed later.
}




public func .. (left:UIView, right:NSLayoutAttribute) -> LayoutArgument {
	return	(left,right)
}

public func ~~ (left:NSLayoutConstraint, right:UILayoutPriority) -> NSLayoutConstraint {
	let	c1	=	NSLayoutConstraint(item: left.firstItem, attribute: left.firstAttribute, relatedBy: left.relation, toItem: left.secondItem, attribute: left.secondAttribute, multiplier: left.multiplier, constant: left.constant)
	c1.priority	=	right
	return	c1
}


public func * (left:LayoutArgument, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left, multiplier: right, constant: 0)
}

public func + (left:LayoutExpression, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left.argument, multiplier: left.multiplier, constant: right)
}

public func - (left:LayoutExpression, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left.argument, multiplier: left.multiplier, constant: -right)
}


public func == (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.Equal, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}
public func >= (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}
public func <= (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}

public func == (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}
public func >= (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}
public func <= (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}




private func assertForCorrectAutoresigingTranslationState(v:UIView) {
	assert(v.translatesAutoresizingMaskIntoConstraints() == false, "The feature `translatesAutoresizingMaskIntoConstraints` never works with auto-layout. Please turn it off.")
}


