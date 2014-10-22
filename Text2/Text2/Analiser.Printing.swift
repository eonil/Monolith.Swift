//
//  Analiser.Printing.swift
//  Text2
//
//  Created by Hoon H. on 10/22/14.
//
//

import Foundation


extension Cursor: Printable {
	var description: String {
		get {
			switch self {
			case Cursor.None:											return	"(Cursor.None)"
			case let Cursor.Available(current: e1, continuation: c1):	return	"(Cursor.Available: current=\(e1))"
			}
		}
	}
}
extension Status: Printable {
	var description:String {
		get {
			switch self {
			case Cancel:								return "(CANCEL)"
			case None:									return "(NONE)"
			case let Done(data: n1, continuation: c1):	return "(DONE: node=\(n1), continuation=\(c1)"
			}
		}
	}
}

extension Node: Printable {
	var description:String {
		get {
			return	"(NODE: cls=\(annotation), key=\(keypoint), comps=\(components), subns=\(subnodes))"
		}
	}
}

extension NodeList: Printable {
	var description:String {
		get {
			var	s1	=	"" as String
			s1		+=	"["
			
			var	g1	=	self.generate()
			while let v1 = g1.next() {
				s1	+=	v1.description + ", "
			}
			
			s1		+=	"]"
			return	s1
		}
	}
}




extension Component: Printable {
	var description:String {
		get {
			switch self {
			case let Component.Error(s):	return	"(Comp: error=\(s.message))"
			case let Component.Value(s):	return	"(Comp: value=\(s.data()))"
			}
		}
	}
}
extension ComponentList: Printable {
	var description:String {
		get {
			var	s1	=	"" as String
			s1		+=	"["
			
			var	g1	=	self.generate()
			while let v1 = g1.next() {
				s1	+=	v1.description + ", "
			}
			
			s1		+=	"]"
			return	s1
		}
	}
}







