////
////  Parsing.CharacterConsumer.swift
////  OSMService
////
////  Created by Hoon H. on 9/8/14.
////  Copyright (c) 2014 Eonil. All rights reserved.
////
//
//import Foundation
//
//
//
//
//
//
//
//
//
//
//
//
//public extension
//Parsing
//{
//	public struct
//	CharacterConsumer
//	{
//		public init(generator:String.Generator)
//		{
//			self.generator	=	generator
//		}
//		
//		public func
//		consume(character:Character, with apply:(value:Character) -> ()) -> CharacterConsumer?
//		{
//			
//			var	g1	=	generator
//			if let ch1 = g1.next()
//			{
//				apply(value: ch1)
//				return	CharacterConsumer(generator: g1)
//			}
//			return	nil
//		}
//		
//		public func
//		consume(string:String, with apply:(value:String) -> ()) -> CharacterConsumer?
//		{
//			var	s1		=	""
//			var	con1	=	self
//			for ch1 in string
//			{
//				if let con2 = con1.consume(ch1, { v in s1.append(v) })
//				{
//					con1	=	con2
//				}
//				else
//				{
//					return	nil
//				}
//			}
//			apply(value: s1)
//			return	con1
//		}
//		
//		
//		
//		public func
//		consume(anyCharactersBy amount:Int, withApplyingAsEachCharacter apply:(value:Character) -> ()) -> CharacterConsumer?
//		{
//			var	g1	=	generator
//			for i in 0..<amount
//			{
//				if let ch1 = g1.next()
//				{
//					apply(value: ch1)
//				}
//				else
//				{
//					return	nil
//				}
//			}
//			return	CharacterConsumer(generator: g1)
//		}
//		
//		///	Applies with empty string if there's no more string left.
//		public func
//		consume(anyCharactersBy amount:Int, withApplyingAsUnionString apply:(value:String) -> ()) -> CharacterConsumer?
//		{
//			var	s1	=	""
//			let	c2	=	consume(anyCharactersBy: amount, withApplyingAsEachCharacter: { v in s1.append(v) })
//			apply(value: s1)
//			return	c2
//		}
//		
//		
//		
//		
//		var	generator:String.Generator
//	}
//}