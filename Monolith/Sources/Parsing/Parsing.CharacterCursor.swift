////
////  Parsing.CharacterCursor.swift
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
//extension
//Parsing
//{
//	public struct
//	CharacterCursor
//	{
//		public init(characters:String)
//		{
//			_chs	=	characters
//			_cidx	=	_chs.startIndex
//		}
//		
//		////
//		
//		public var available:Bool
//		{
//			get
//			{
//				return	_cidx < _chs.endIndex
//			}
//		}
//		public var current:Character
//		{
//			get
//			{
//				return	_chs[_cidx]
//			}
//		}
//		public func stepping() -> CharacterCursor
//		{
//			var	cc2		=	self
//			cc2.step()
//			return	cc2
//		}
//		public func stepping(by amount:Int) -> CharacterCursor
//		{
//			var	cc2	=	self
//			cc2.step(by: amount)
//			return	cc2
//		}
////		public func steppingAvailable(by amount:Int) -> CharacterCursor
////		{
////			var	cc2	=	self
////			cc2.stepAvailable(by: amount)
////			return	cc2
////		}
//		
//		public func string(to cursor:CharacterCursor) -> String
//		{
//			assert(cursor._cidx >= _cidx)
//			return	_chs[Range<String.Index>(start: _cidx, end: cursor._cidx)]
//		}
//		public func string(from cursor:CharacterCursor) -> String
//		{
//			assert(cursor._cidx <= _cidx)
//			return	_chs[Range<String.Index>(start: cursor._cidx, end: _cidx)]
//		}
//		
//		////
//		
//		public mutating func step()
//		{
//			assert(_cidx < _chs.endIndex)
//			
//			_cidx	=	_cidx.successor()
//		}
//		
//		///	Crashes if available characters are not enough.
//		public mutating func step(by amount:Int)
//		{
//			for _ in 0..<amount
//			{
//				assert(available)
//				step()
//			}
//		}
//		
////		///	Stops at end if available characters are not enough.
////		public mutating func stepAvailable(by amount:Int)
////		{
////			for _ in 0..<amount
////			{
////				if available == false
////				{
////					return
////				}
////				step()
////			}
////		}
//		
//		////
//		
//		private var	_cidx:String.Index
//		private let	_chs:String
//	}
//}