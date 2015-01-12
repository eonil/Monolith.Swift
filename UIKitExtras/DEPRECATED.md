




Collection of Deprecated Text
-----------------------------





Defines declarative relation between layot metrices.

self.view.layoutConstraints	=	[
view1..width	==	view2..width * 1 + 0,
view1..height	==	view2..height * 0 + 100,
]

You also can set priority.


self.view.layoutConstraints	=	[
view1..width	==	view2..width * 1 + 0	~~~	100,
view1..height	==	view2..height * 0 + 100	~~~	300,
]


