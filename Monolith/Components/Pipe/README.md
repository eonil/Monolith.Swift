PIPE
====
Hoon H.




**Pipe** provides reactive I/O programming building blocks.








Thread Safety 
-------------
Any task can shift signaling thread at any time. You shouldn't make any 
assumption of signaling thread. The best practice is explicitly routing 
signals to desired thread.




Push vs Pull Network
--------------------
All signaling nodes are push based by default because the signals are 
coming from event-based (asynchronous) external I/O sources. And these
pushing nodes can be converted into pulling nodes using buffer node.