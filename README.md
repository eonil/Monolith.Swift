Monolith.Swift
==============
Hoon H.



Monolithic collection of multiple features in Apple Swift.
Written by Hoon H..

In my opinion, Swift tends to separate each features smaller modules 
rather than a big one module. I separated each featuers into each of
small projects, and you can use the feature you want. Dependencies 
are all baked in on each projects, and you don't need to care on it.







Features - Operators
--------------------

-	`|||` nil-or operator.


`Standards` Features (Full Implementations)
-------------------------------------------

-	RFC 3339 timestamp scanning and printing. (Pure Swift)
-	RFC 4627 JSON scanning and printing. (Cocoa inter-op)

ISO 8601 is avoided in favor of RFC 3339.




`Standards` Features (Partial Implementations)
----------------------------------------------
These features are implementation of very small portion of a large 
standard.

-	RFC 1808 URL query-string scanning and printing. (Cocoa inter-op)
-	RFC 2616 Predefined HTTP method constants. (Pure Swift)




License
-------
MIT license.

