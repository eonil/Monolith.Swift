UIKitExtras
============
2014/11/19
Hoon H.




Provides clear and convenient anchor based auto-layout utilities.
This does not fully cover all of autolayout-constraint semantics. Provides only most frequently used stuffs.






How to Use
----------

This code

	authorLabel.topAnchor				==	self.topAnchor,
	downloadCountLabel.bottomAnchor		==	self.bottomAnchor,

makes `authorLabel`'s top border to be attached to `self`'s top border.
Also makes `downloadCountLabel`'s  bottom border to be attached to `self`'s botto border.


This code

	view1.addConstraintsWithLayoutAnchoring([
		view2.centerAnchor	==	view3.centerAnchor,
		view2.sizeAnchor	<=	view3.sizeAnchor,
		], priority: 750)

will make `view2`'s center will be attached to `view3`'s center.
And limits `view2`'s size to be equals or smaller than `view3`'s size.










Operator based utilities has been deprecated.
---------------------------------------------

It's because,

-	It's unclear and ambiguous. Semantics of rare operators are not well-known, and plain English function is far better to be parsed by human programmers.
-	It's natually incompatible. Everyone can define their own operators with their own semantics. 
-	It's slow. This is due to immature compiler, but anyway, it's *currently* slow to compile.

Now it is anti-goal to provide custom operators unless we have some very widely agreed operators.









License
-------
This follows `Monolith.Swift` framework licensing terms that is MIT license.