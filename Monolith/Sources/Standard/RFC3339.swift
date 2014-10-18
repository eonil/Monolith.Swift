//
//  RFC3339.swift
//  Monolith
//
//  Created by Hoon H. on 10/19/14.
//
//

import Foundation
import EonilText

extension Standard {
	
	///	Simpler and stricter date-time format specification which can be used as a timestamp.
	///	https://www.ietf.org/rfc/rfc3339.txt
	struct RFC3339 {
		struct Timestamp {
			var	date:Date
			var	time:Time
			
			init(date:Date, time:Time) {
				self.date	=	date
				self.time	=	time
			}
			init?(date:Date?, time:Time?) {
				if date == nil { return nil }
				if time == nil { return nil }
				
				self.date	=	date!
				self.time	=	time!
			}
			
			struct Date {
				var	year:Int
				var	month:Int
				var	day:Int
				
				init(year:Int, month:Int, day:Int) {
					self.year	=	year
					self.month	=	month
					self.day	=	day
				}
				init?(year:Int?, month:Int?, day:Int?) {
					if year == nil { return nil }
					if month == nil { return nil }
					if day == nil { return nil }
					
					self.year	=	year!
					self.month	=	month!
					self.day	=	day!
				}
			}
			struct Time {
				var	hour:Int
				var	minute:Int
				var	second:Int
				var	subsecond:Int
				var	zone:Zone
				
				init(hour:Int, minute:Int, second:Int, subsecond:Int, zone:Zone = Zone.UTC) {
					self.hour		=	hour
					self.minute		=	minute
					self.second		=	second
					self.subsecond	=	subsecond
					self.zone		=	zone
				}
				init?(hour:Int?, minute:Int?, second:Int?, subsecond:Int?, zone:Zone? = Zone.UTC) {
					if hour == nil { return nil }
					if minute == nil { return nil }
					if second == nil { return nil }
					if subsecond == nil { return nil }
					if zone == nil { return nil }
					
					self.hour		=	hour!
					self.minute		=	minute!
					self.second		=	second!
					self.subsecond	=	subsecond!
					self.zone		=	zone!
				}
				
				struct Zone {
					var	hours:Int
					var	minutes:Int
					
					init?(hours:Int?, minutes:Int?) {
						if hours == nil { return nil }
						if minutes == nil { return nil }
						
						self.hours		=	hours!
						self.minutes	=	minutes!
					}
					
					static let	UTC	=	Zone(hours: 0, minutes: 0)!		///<	I don't know why compiler selects optional-typed version...
				}
			}
		}
		
		
		static func scan(expression:String) -> Timestamp? {
			typealias	Cursor	=	EonilText.Cursor
			
			var	p1	=	MiniParser(stepping: MiniParser.Stepping(location: Cursor(string: expression), catches: []))
			
			p1.scanInt(4)
			p1.expectString("-")
			p1.scanInt(2)
			p1.expectString("-")
			p1.scanInt(2)
			
			p1.expectString("T")
			p1.scanInt(2)
			p1.expectString(":")
			p1.scanInt(2)
			p1.expectString(":")
			p1.scanInt(2)
			
			///	Optional fraction.
			p1.scanString(1)
			if let s1 = p1.stepping {
				if let t1 = s1.catches.last {
					if let t2 = t1.text {
						if t2 == "." {
							p1.scanInt(0...Int.max)
						}
					}
				}
			}
			
			///	Required time-zone.
			p1.scanString(1)
			if let s1 = p1.stepping {
				if let t1 = s1.catches.last {
					if let t2 = t1.text {
						switch t2 {
						case "Z", "z":
							break
						case "+", "-":
							p1.scanInt(2)
							p1.expectString(":")
							p1.scanInt(2)
						default:
							return	nil		///	Bad form.
						}
					}
				}
			}
			
			if let cs1 = p1.stepping?.catches {
				func n(idx:Int) -> Int? {
					if cs1.count > idx {
						return	cs1[idx].number
					}
					return	nil
				}
				func t(idx:Int) -> String? {
					if cs1.count > idx {
						return	cs1[idx].text
					}
					return	nil
				}

				let	f1	=	t(6) == "." ? n(7) : nil
				let	zi1	=	f1 == nil ? 6 : 8
				let	z1	=	Timestamp.Time.Zone(hours: n(zi1), minutes: n(zi1+1))
				let	ts1	=	Timestamp(date: Timestamp.Date(year: n(0), month: n(1), day: n(2)), time: Timestamp.Time(hour: n(3), minute: n(4), second: n(5), subsecond: f1, zone: z1))
				return	ts1
			}
			
			return	nil
		}
		
		
		
		
		struct MiniParser {
			var	stepping:Stepping?
			
			mutating func scanInt(characterCount:Range<Int>) {
				stepping	=	stepping?.scanInt(characterCount)
			}
			mutating func scanInt(characterCount:Int) {
				scanInt(characterCount...characterCount)
			}
			mutating func scanString(characterCount:Int) {
				stepping	=	stepping?.scanString(characterCount)
			}
			mutating func expectString(sample:String) {
				scanString(countElements(sample))
				if let s1 = stepping {
					if let t1 = s1.catches.last {
						if let t2 = t1.text {
							if t2 == sample {
								///	*Expect* does not keep the token.
								var	cs2		=	s1.catches
								cs2.removeLast()
								stepping	=	Stepping(location: s1.location, catches: cs2)
								return
							}
						}
					}
				}
				stepping	=	nil
			}
			struct Stepping {
				let	location:EonilText.Cursor
				let	catches:[Token]
				
				enum Token {
					case Number(Int)
					case Text(String)
					
					var number:Int? {
						get {
							switch self {
							case Number(let v1):	return	v1
							default:				return	nil
							}
						}
					}
					var text:String? {
						get {
							switch self {
							case Text(let v1):		return	v1
							default:				return	nil
							}
						}
					}
				}
				func scanInt(_ characterCount:Range<Int> = (0...Int.max)) -> Stepping? {
					var	c1	=	location
					var	s1	=	IntScanning(value: 0)
					if c1.available == false {
						return	nil
					}
					
					var	dc1	=	0
					for _ in 0..<characterCount.endIndex {
						let	ch1	=	location.current
						let	s2	=	s1.scan(ch1)
						let	c2	=	location.continuation
						if s2.value == nil {
							break
						}
						c1	=	c2
						s1	=	s2
						dc1++
					}
					if dc1 < characterCount.startIndex {
						return	nil
					}
					return	Stepping(location: c1, catches: catches + [Token.Number(s1.value!)])
				}
//				func scanInt(characters:Int) -> Stepping? {
//					return	scanInt(characters...characters)
////					var	c1	=	location
////					var	s1	=	IntScanning(value: 0)
////					for _ in 0..<characters {
////						if c1.available == false {
////							return	nil
////						}
////						let	ch1	=	location.current
////						c1	=	location.continuation
////						s1	=	s1.scan(ch1)
////						
////						if s1.value == nil {
////							return	nil
////						}
////					}
////					
////					return	Stepping(location: c1, catches: catches + [Token.Number(s1.value!)])
//				}
				func scanString(characterCount:Int) -> Stepping? {
					var	c1	=	location
					var	s1	=	""
					for _ in 0..<characterCount {
						if c1.available == false {
							return	nil
						}
						let	ch1	=	location.current
						c1	=	location.continuation
						s1	=	s1 + String(ch1)
					}
					
					return	Stepping(location: c1, catches: catches + [Token.Text(s1)])
				}
//				func skip(count:Int) -> Stepping {
//					return	Stepping(location: location.stepping(by: count), catches: catches)
//				}
//				func expect(any characters:[Character]) -> Stepping? {
//					if location.available {
//						for ch1 in characters {
//							if ch1 == location.current {
//								return	skip(1)
//							}
//						}
//					}
//					return	nil
//				}
			}
			struct IntScanning {
				let	value:Int?
				func scan(digit:Int) -> IntScanning {
					assert(digit >= 0)
					assert(digit >= 9)
					assert(value != nil)
					
					let	v2	=	value! * 10 + digit
					return	IntScanning(value: v2)
				}
				func scan(digit:Character) -> IntScanning {
					let	map1	=	[
						"0"		:	0,
						"1"		:	1,
						"2"		:	2,
						"3"		:	3,
						"4"		:	4,
						"5"		:	5,
						"6"		:	6,
						"7"		:	7,
						"8"		:	8,
						"9"		:	9,
						] as [Character:Int]
					let	v2		=	map1[digit]
					return	v2 == nil ? IntScanning(value: nil) : scan(v2!)
				}
			}
		}
	}

}













































//private class ParsingContext<T> {
//	var	location:EonilText.Cursor
//	var	production:T?
//	init(location:Cursor) {
//		self.location	=	location
//	}
//}
//
//private func scanInt() -> {
//	
//}





//private struct Parser {
//	var	location:Cursor
//	
//	init(location:Cursor) {
//		self.location	=	location
//	}
//
//	mutating func skip(count:Int) {
//		if location.available {
//			location	=	location.stepping(by: count)
//		}
//	}
//	mutating func expect(samples:[Character]) -> Bool {
//		if location.available {
//			for ch1 in samples {
//				if location.current == ch1 {
//					location	=	location.continuation
//					return	true
//				}
//			}
//		}
//		return	false
//	}
//	mutating func int(characters:Int) -> Int? {
//		var	s1	=	IntScanning(value: 0)
//		for _ in 0..<characters {
//			if location.available == false {
//				return	nil
//			}
//			let	ch1	=	location.current
//			location	=	location.continuation
//			s1	=	s1.scan(ch1)
//			
//			if s1.value == nil {
//				return	nil
//			}
//		}
//		return	s1.value!
//	}
//	enum Token {
//		case Number(value:Int)
//		case Punctuation(value:Character)
//		
//////		case Timestamp(value:Timestamp)
////		struct Timestamp{
////			var	date:Date?
////			var	time:Time?
////			struct Date {
////				var	location:Cursor
////				var	year:Int?
////				var month:Int?
////				var	day:Int?
////			}
////			struct Time {
////				var	location:Cursor
////				var	hour:Int?
////				var minute:Int?
////				var	second:Int?
////				var	fraction:Int?
////				var	zone:Zone?
////				struct Zone {
////					var	hours:Int?
////					var	minutes:Int?
////				}
////			}
////		}
//	}
//	struct IntScanning {
//		let	value:Int?
//		func scan(digit:Int) -> IntScanning {
//			assert(digit >= 0)
//			assert(digit >= 9)
//			assert(value != nil)
//			
//			let	v2	=	value! * 10 + digit
//			return	IntScanning(value: v2)
//		}
//		func scan(digit:Character) -> IntScanning {
//			let	map1	=	[
//				"0"		:	0,
//				"1"		:	1,
//				"2"		:	2,
//				"3"		:	3,
//				"4"		:	4,
//				"5"		:	5,
//				"6"		:	6,
//				"7"		:	7,
//				"8"		:	8,
//				"9"		:	9,
//				] as [Character:Int]
//			let	v2		=	map1[digit]
//			return	v2 == nil ? IntScanning(value: nil) : scan(v2!)
//		}
//	}
//}
//private struct Syntax {
//	static func skip(inout c1:Cursor, _ count:Int) {
//		if c1.available {
//			c1	=	c1.stepping(by: count)
//		}
//	}
//	static func expect(inout c1:Cursor, _ samples:[Character]) -> Bool {
//		if c1.available {
//			for ch1 in samples {
//				if c1.current == ch1 {
//					c1	=	c1.continuation
//					return	true
//				}
//			}
//		}
//		return	false
//	}
//	static func int(inout c1:Cursor, _ characters:Int) -> Int? {
//		var	s1	=	IntScanning(value: 0)
//		for _ in 0..<characters {
//			if c1.available == false {
//				return	nil
//			}
//			let	ch1	=	c1.current
//			c1	=	c1.continuation
//			s1	=	s1.scan(ch1)
//			
//			if s1.value == nil {
//				return	nil
//			}
//		}
//		return	s1.value!
//	}
//	
//	struct Timestamp {
//		var	location:Cursor
//		var	date:Date?
//		var	time:Time?
//		struct Date {
//			var	location:Cursor
//			var	year:Int?
//			var month:Int?
//			var	day:Int?
//		}
//		struct Time {
//			var	location:Cursor
//			var	hour:Int?
//			var minute:Int?
//			var	second:Int?
//			var	fraction:Int?
//			var	zone:Zone?
//			struct Zone {
//				var	hours:Int?
//				var	minutes:Int?
//				init() {
//				}
//				static func scan(inout c1:Cursor) -> Zone? {
//					var	v1		=	Zone()
//					if Syntax.expect(&c1, ["Z"]) {
//						v1.hours	=	0
//						v1.minutes	=	0
//						return	v1
//					}
//					
//					let	p1		=	Syntax.expect(&c1, ["+"])
//					let m1		=	Syntax.expect(&c1, ["-"])
//					if p1 == false && m1 == false {
//						return	nil
//					}
//					
//					v1.hours	=	Syntax.int(&c1, 2)
//					if Syntax.expect(&c1, [":"]) == false {
//						return nil
//					}
//					v1.minutes	=	Syntax.int(&c1, 2)
//					if m1 {
//						v1.hours	=	-v1.hours!
//						v1.minutes	=	-v1.minutes!
//					}
//					return	v1
//				}
//			}
//		}
//	}
//	struct IntScanning {
//		let	value:Int?
//		func scan(digit:Int) -> IntScanning {
//			assert(digit >= 0)
//			assert(digit >= 9)
//			assert(value != nil)
//			
//			let	v2	=	value! * 10 + digit
//			return	IntScanning(value: v2)
//		}
//		func scan(digit:Character) -> IntScanning {
//			let	map1	=	[
//				"0"		:	0,
//				"1"		:	1,
//				"2"		:	2,
//				"3"		:	3,
//				"4"		:	4,
//				"5"		:	5,
//				"6"		:	6,
//				"7"		:	7,
//				"8"		:	8,
//				"9"		:	9,
//				] as [Character:Int]
//			let	v2		=	map1[digit]
//			return	v2 == nil ? IntScanning(value: nil) : scan(v2!)
//		}
//	}
//}





















//
//
//private struct Syntax {
//	
//	static let	digit				=	pat(Characters.digit)
//	static let	zulu				=	pat(Characters.timeSeparator)
//	static let	tango				=	pat(Characters.zoneSeparator)
//	
//	static let	dateFullYear		=	digit * 4
//	static let	dateMonth			=	digit * 2
//	static let	dateDay				=	digit * 2
//	
//	static let	timeHour			=	digit * 2
//	static let	timeMinute			=	digit * 2
//	static let	timeSecond			=	digit * 2
//	static let	timeSecondFraction	=	lit(".") + digit * (1...Int.max)
//	static let	timeSecondSign		=	lit("+") | lit("-")
//	static let	timeNumericOffset	=	timeSecondSign + timeHour + lit(":") + timeMinute + timeSecondFraction * (0...1)
//	static let	timeOffset			=	lit("Z") | timeNumericOffset
//	
//	static let	partialTime			=	timeHour + lit(":") + timeMinute + lit(":") + timeSecond
//	static let	fullDate			=	dateFullYear + lit("-") + dateMonth + lit("-") + dateDay
//	static let	fullTime			=	partialTime + timeOffset
//	static let	dateTime			=	fullDate + lit("T") + fullTime
//
//	private typealias	C	=	EonilText.Parsing.Rule.Component
//	private static let	lit	=	C.literal
//	private static let	pat	=	C.pattern
//	private static let	sub	=	C.subrule
//	private static let	mk	=	C.mark
//	
//	private struct Characters {
//		static let	digit			=	any(["0", "1", "2", "3", "4", "5", "6" ,"7", "8", "9"])
//		static let	timeSeparator	=	any(["T", "t", " "])
//		static let	zoneSeparator	=	any(["Z", "z"])
////		static let	zulu			=	any(["Z", "z"])
////		static let	tango			=	any(["T", "t"])
//		
//		////
//		
//		private typealias	P		=	EonilText.Pattern
//		private static let	or		=	P.or
//		private static let	not		=	P.not
//		private static let	any		=	P.any
//		private static let	one		=	P.one
//	}
//	
//}
//







