//
//  LayoutConstraint.swift
//  WeatherTable
//
//  Created by Hoon H. on 11/18/14.
//
//

import Foundation
import UIKit




@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public struct LayoutExpression {
	public let	argument:LayoutArgument
	public let	multiplier:CGFloat
	public let	constant:CGFloat
}

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public typealias	LayoutArgument	=	(view: UIView, attribute:NSLayoutAttribute)

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	width		=	NSLayoutAttribute.Width
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	height		=	NSLayoutAttribute.Height
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	centerX		=	NSLayoutAttribute.CenterX
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	centerY		=	NSLayoutAttribute.CenterY

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	left		=	NSLayoutAttribute.Left
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	right		=	NSLayoutAttribute.Right
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	top			=	NSLayoutAttribute.Top
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.") public let	bottom		=	NSLayoutAttribute.Bottom

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public let	baseline	=	NSLayoutAttribute.Baseline




infix operator .. {
	precedence 255			///	Precedence may be changed later.
}

infix operator ~~ {
	precedence 1			///	Precedence may be changed later.
}



@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func .. (left:UIView, right:NSLayoutAttribute) -> LayoutArgument {
	return	(left,right)
}

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func ~~ (left:NSLayoutConstraint, right:UILayoutPriority) -> NSLayoutConstraint {
	let	c1	=	NSLayoutConstraint(item: left.firstItem, attribute: left.firstAttribute, relatedBy: left.relation, toItem: left.secondItem, attribute: left.secondAttribute, multiplier: left.multiplier, constant: left.constant)
	c1.priority	=	right
	return	c1
}


@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func * (left:LayoutArgument, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left, multiplier: right, constant: 0)
}

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func + (left:LayoutExpression, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left.argument, multiplier: left.multiplier, constant: right)
}

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func - (left:LayoutExpression, right:CGFloat) -> LayoutExpression {
	return	LayoutExpression(argument: left.argument, multiplier: left.multiplier, constant: -right)
}


@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func == (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.Equal, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func >= (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func <= (left:LayoutArgument, right:LayoutExpression) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: right.argument.view, attribute: right.argument.attribute, multiplier: right.multiplier, constant: right.constant)
}

@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func == (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func >= (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.GreaterThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}
@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
public func <= (left:LayoutArgument, right:CGFloat) -> NSLayoutConstraint {
	assertForCorrectAutoresigingTranslationState(left.view)
	return	NSLayoutConstraint(item: left.view, attribute: left.attribute, relatedBy: NSLayoutRelation.LessThanOrEqual, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0, constant: right)
}




@availability(*,deprecated=0.0,message="Single constraint expression deprecated. Please migrate to anchor based one. See `Anchor` for details.")
private func assertForCorrectAutoresigingTranslationState(v:UIView) {
	assert(v.translatesAutoresizingMaskIntoConstraints() == false, "The feature `translatesAutoresizingMaskIntoConstraints` never works with auto-layout. Please turn it off.")
}


