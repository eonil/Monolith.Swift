//
//  All.swift
//  Monolith
//
//  Created by Hoon H. on 10/25/14.
//
//

import Foundation

struct Tests {
	static func runAll() {
		Standard.RFC1808.Test.run()
		Standard.RFC3339.Test.run()
		Standard.RFC2616.Test.run()
		Standard.RFC4627.Test.run()
		println("All test OK.")
	}
}