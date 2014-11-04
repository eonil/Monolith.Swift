// Playground - noun: a place where people can play

import Foundation
import AsynchronousFramework


let	f1	=	FilterOf { $0 + 1 }
let	f2	=	FilterOf { $0 * 10 }

let	f3	=	0 >>> f2 >>> f1


