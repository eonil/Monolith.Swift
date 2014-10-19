//
//  RFC3339.swift
//  Monolith
//
//  Created by Hoon H. on 10/19/14.
//
//

import Foundation
import EonilText

public extension Standard {
	
	///	Simpler and stricter date-time format specification which can be used as a timestamp.
	///	https://www.ietf.org/rfc/rfc3339.txt
	///
	///	RFC3339 is explicit *timestamp* format. It is very simple and strict, and unambiguous.
	///	You're specifying a *time-point* rather than a *time-span*. Then you cannot omit any
	///	component of a timestamp which makes it ambiguous. If you want to repsent a time-span
	///	use your own Timespan type which is consist of two timestamps. The timespan type is not 
	///	a part of RFC3339, so it is not here.
	public struct RFC3339 {
		public struct Timestamp {
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
			
			public struct Date {
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
			public struct Time {
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
//				///	Returns UTC based timestamp.
//				///	This needs involving of fully established calendar stuff,
//				///	so it's very expensive.
//				func normalise() -> Time {
//					return	Time(hour: hour + zone.hours, minute: minute + zone.minutes, second: second, subsecond: subsecond, zone: Zone.UTC)
//				}
				
				public struct Zone {
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
			
			static let	zero	=	Timestamp(date: Timestamp.Date(year: 0, month: 0, day: 0), time: Timestamp.Time(hour: 0, minute: 0, second: 0, subsecond: 0, zone: Timestamp.Time.Zone(hours: 0, minutes: 0)))!
		}
		
		
		public static func scan(expression:String) -> Timestamp? {
			var	p1	=	Parser(expression: expression)
			p1.scan()
			let	ok	=	p1.scanner.stepping?.location.available == false	///	Expression must be fully consumed.
			return	ok && p1.ok ? p1.timestamp : nil
		}
		
	}
}
















///	MARK:
private extension Standard.RFC3339 {
	///	Optimised as a mutable imperative parser.
	///	Designed to avoid dynamic allocations as much as possible.
	///	(e.g. `String`, `Array<T>`, ...)
	struct Parser {
		var	scanner:Scanner
		var	timestamp:Timestamp
		var	ok:Bool
		
		init(expression:String) {
			self.scanner	=	Scanner(expression: expression)
			self.timestamp	=	Timestamp.zero
			self.ok			=	true
		}
		
		mutating func scan() {
			scanDate()
			let	g1	=	scanner.scanGlyph()
			if let g2 = g1 {
				switch g2 {
				case "T", " ", "t":
					scanTime()
					return
				default:
					break
				}
			}
			ok	=	false
		}
		mutating func scanDate() {
			if !ok { return }
			set(&timestamp.date.year, byScanningCharacters: 4)
			check("-")
			set(&timestamp.date.month, byScanningCharacters: 2)
			check("-")
			set(&timestamp.date.day, byScanningCharacters: 2)
		}
		mutating func scanTime() {
			if !ok { return }
			set(&timestamp.time.hour, byScanningCharacters: 2)
			check(":")
			set(&timestamp.time.minute, byScanningCharacters: 2)
			check(":")
			set(&timestamp.time.second, byScanningCharacters: 2)
			
			let	g3	=	scanner.peekGlyph()
			if let g4 = g3 {
				if g4 == "." {
					scanner.skipGlyph()
					set(&timestamp.time.subsecond, byScanningCharacters: 1..<Int.max)
				}
				
				let	g5	=	scanner.scanGlyph()
				if let g6 = g5 {
					switch g6 {
					case "Z", "z":
						timestamp.time.zone			=	Timestamp.Time.Zone.UTC
						return
					case "+":
						scanTimeZone()
						return
					case "-":
						scanTimeZone()
						timestamp.time.zone.hours	=	-timestamp.time.zone.hours
						timestamp.time.zone.minutes	=	-timestamp.time.zone.minutes
						return
					default:
						break
					}
				}
			}
			ok	=	false
		}
		mutating func scanTimeZone() {
			set(&timestamp.time.zone.hours, byScanningCharacters: 2)
			check(":")
			set(&timestamp.time.zone.minutes, byScanningCharacters: 2)
		}
		mutating func set(inout destination:Int, byScanningCharacters c1:Range<Int>) {
			if !ok { return }
			let	v1		=	scanner.scanInt(c1)
			ok			=	v1 != nil
			destination	=	v1 ||| 0
		}
		mutating func set(inout destination:Int, byScanningCharacters c1:Int) {
			set(&destination, byScanningCharacters: c1...c1)
		}
		mutating func check(sample:Character) {
			if !ok { return }
			let	v1		=	scanner.scanGlyph()
			ok			=	v1 == sample
		}
	}
	
	///	Token scanner.
	struct Scanner {
		var	stepping:Stepping?
		
		init(expression:String) {
			self.stepping	=	Stepping(location: Cursor(string: expression), catching: nil)
		}
		
		mutating func scanInt(characterCount:Range<Int>) -> Int? {
			stepping	=	stepping?.scanInt(characterCount)
			return	stepping?.catching?.number
		}
		mutating func scanGlyph() -> Character? {
			stepping	=	stepping?.scanGlyph()
			return	stepping?.catching?.glyph
		}
		///	Previews current glyph without advancing the cursor.
		mutating func peekGlyph() -> Character? {
			let	s1	=	stepping?.scanGlyph()
			return	s1?.catching?.glyph
		}
		mutating func skipGlyph() {
			scanGlyph()
		}
		
		////
		
		struct Stepping {
			let	location:EonilText.Cursor
			let	catching:Token?
			
			enum Token {
				case Number(Int)
				case Glyph(Character)
				
				var number:Int? {
					get {
						switch self {
						case Number(let v1):	return	v1
						default:				return	nil
						}
					}
				}
				var glyph:Character? {
					get {
						switch self {
						case Glyph(let v1):		return	v1
						default:				return	nil
						}
					}
				}
			}
			func scanInt(characterCount:Range<Int>) -> Stepping? {
				assert(characterCount.startIndex <= characterCount.endIndex)
				if characterCount.endIndex == 0 {
					return	nil
				}
				
				var	c1	=	location
				var	s1	=	IntStacking(value: 0)
				if c1.available == false {
					return	nil
				}
				
				var	dc1	=	0
				for _ in 0..<(characterCount.endIndex-1) {
					let	ch1	=	c1.current
					let	s2	=	s1.scan(ch1)
					let	c2	=	c1.continuation
					
					if s2.value == nil {
						break
					}

					dc1++
					c1	=	c2
					s1	=	s2
				}
				if dc1 < characterCount.startIndex {
					return	nil
				}
				return	Stepping(location: c1, catching: Token.Number(s1.value!))
			}
			func scanGlyph() -> Stepping? {
				if location.available == false {
					return	nil
				}
				let	ch1	=	location.current
				return	Stepping(location: location.continuation, catching: Token.Glyph(ch1))
			}
		}
		
		
		struct IntStacking {
			let	value:Int?
			func scan(digit:Int) -> IntStacking {
				assert(digit >= 0)
				assert(digit <= 9)
				assert(value != nil)
				if value == nil { return self }

				///	Any overflow will become `nil`.
				let	v2			=	value!
				let	(v3, f3)	=	Int.multiplyWithOverflow(v2, 10)
				let	(v4, f4)	=	f3 ? (0, false) : Int.addWithOverflow(v3, digit)
				return	IntStacking(value: f4 ? nil : v4)
			}
			func scan(digit:Character) -> IntStacking {
				func determineDigit() -> Int? {
					///	Can be optimised further by utilising code-point.
					///	But I am not sure that would be actually better...
					///	Also there's no known way to get code-point from `Character`.
					///	And, I believe compiler can be smart enough to optimise this
					///	because this is essentially very regular integer -> integer 
					///	mappings. Then, this seems to be better for compiler pattern 
					///	detection.
					switch digit {
					case "0":	return	0
					case "1":	return	1
					case "2":	return	2
					case "3":	return	3
					case "4":	return	4
					case "5":	return	5
					case "6":	return	6
					case "7":	return	7
					case "8":	return	8
					case "9":	return	9
					default:	return	nil
					}
				}
				let	v2	=	determineDigit()
				return	v2 == nil ? IntStacking(value: nil) : scan(v2!)
			}
		}
	}

}





//func == (l:Standard.RFC3339.Timestamp, r:Standard.RFC3339.Timestamp) -> Bool {
//}
//func == (l:Standard.RFC3339.Timestamp.Date, r:Standard.RFC3339.Timestamp.Date) -> Bool {
//}
//func == (l:Standard.RFC3339.Timestamp.Time, r:Standard.RFC3339.Timestamp.Time) -> Bool {
//}
//func == (l:Standard.RFC3339.Timestamp.Time.Zone, r:Standard.RFC3339.Timestamp.Time.Zone) -> Bool {
//}
//func < (l:Standard.RFC3339.Timestamp, r:Standard.RFC3339.Timestamp) -> Bool {
//	return	l.date < r.date && l.time < r.time
//}
//func < (l:Standard.RFC3339.Timestamp.Date, r:Standard.RFC3339.Timestamp.Date) -> Bool {
//	return	l.year < r.year && l.month < r.month && l.day < r.day
//}
/////	Only timestamps in same time-zone are supported.
//func < (l:Standard.RFC3339.Timestamp.Time, r:Standard.RFC3339.Timestamp.Time) -> Bool {
//	precondition(l.zone == r.zone)
//	return	l.hour < r.hour && l.minute < r.minute && l.second < r.second && l.subsecond < r.subsecond && l.zone < r.zone
//}
//func < (l:Standard.RFC3339.Timestamp.Time.Zone, r:Standard.RFC3339.Timestamp.Time.Zone) -> Bool {
//	return	l.hours < r.hours && l.minutes < r.minutes
//}


































///	MARK:
extension Standard.RFC3339 {
	struct Test {
		static func run() {
			typealias	Token	=	Scanner.Stepping.Token
			func assert(c:@autoclosure()->Bool) {
				if c() == false {
					fatalError("Test assertion failure!")
				}
			}
			func tx(c:()->()) {
				c()
			}
			
			
			
			func happyCases() {
				
				tx{
					let	s1	=	"123"
					var	p1	=	Scanner(expression: s1)
					p1.scanInt(2...2)
					assert(p1.stepping != nil)
					assert(p1.stepping!.location.current == "3")
					assert(p1.stepping!.catching != nil)
					assert(p1.stepping!.catching!.number == 12)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 != nil)
					assert(ts1!.date.year == 1111)
					assert(ts1!.date.month == 22)
					assert(ts1!.date.day == 33)
					assert(ts1!.time.hour == 44)
					assert(ts1!.time.minute == 55)
					assert(ts1!.time.second == 66)
					assert(ts1!.time.subsecond == 0)
					assert(ts1!.time.zone.hours == 0)
					assert(ts1!.time.zone.minutes == 0)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66.7Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 != nil)
					assert(ts1!.date.year == 1111)
					assert(ts1!.date.month == 22)
					assert(ts1!.date.day == 33)
					assert(ts1!.time.hour == 44)
					assert(ts1!.time.minute == 55)
					assert(ts1!.time.second == 66)
					assert(ts1!.time.subsecond == 7)
					assert(ts1!.time.zone.hours == 0)
					assert(ts1!.time.zone.minutes == 0)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66.7+88:99"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 != nil)
					assert(ts1!.date.year == 1111)
					assert(ts1!.date.month == 22)
					assert(ts1!.date.day == 33)
					assert(ts1!.time.hour == 44)
					assert(ts1!.time.minute == 55)
					assert(ts1!.time.second == 66)
					assert(ts1!.time.subsecond == 7)
					assert(ts1!.time.zone.hours == 88)
					assert(ts1!.time.zone.minutes == 99)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66.7-88:99"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 != nil)
					assert(ts1!.date.year == 1111)
					assert(ts1!.date.month == 22)
					assert(ts1!.date.day == 33)
					assert(ts1!.time.hour == 44)
					assert(ts1!.time.minute == 55)
					assert(ts1!.time.second == 66)
					assert(ts1!.time.subsecond == 7)
					assert(ts1!.time.zone.hours == -88)
					assert(ts1!.time.zone.minutes == -99)
				}

			}

			func evilCases() {
				
				tx{
					let	s1	=	"a1111-22-33T44:55:66Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}
				tx{
					let	s1	=	"1111x22-33T44:55:66Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}
				tx{
					let	s1	=	"111-22-33T44:55:66Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}
				tx{
					let	s1	=	"1111-2-33T44:55:66Z"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}
				tx{
					let	s1	=	"1111-22-33T44:55:66Z+00:11"
					let	ts1	=	Standard.RFC3339.scan(s1)
					assert(ts1 == nil)
				}

			}
			
			
			happyCases()
			evilCases()
		}
	}
}



















