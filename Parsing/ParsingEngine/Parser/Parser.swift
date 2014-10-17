//
//  Parser.swift
//  EDXC
//
//  Created by Hoon H. on 10/14/14.
//  Copyright (c) 2014 Eonil. All rights reserved.
//

import Foundation







public func parse(data d1:String, using r1:Rule) -> Stepping {
	let	c1	=	Cursor(code: Code(data: d1), location: d1.startIndex)
	return	r1.parse(c1)
}


