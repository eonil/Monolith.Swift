PIPE
====
Hoon H.




**Pipe** provides reactive I/O programming building blocks.
This is actually more like to a Unix pipe.








Thread Safety 
-------------
Any task can shift signaling thread at any time. You shouldn't make any 
assumption of signaling thread. The best practice is explicitly routing 
signals to desired thread.



Push vs Pull Network
--------------------
All nodes are push based by default because most of the signals are 
coming from asynchronous external I/O sources. And these
pushing nodes can be converted into pulling nodes using buffer node.








Purity
----------------
This framework is not purely functional. It's impossible to make I/O 
stuffs with alien world purely functional. Because there can't be a 
deterministic output for an input. At least I don't know how.

Please watch [this slide](http://www.slideshare.net/borgesleonardo/functional-reactive-programming-compositional-event-systems)
to see why the word `functional` is so important, and carefu to mention.

I hope to see a future genius to make it possible :)

