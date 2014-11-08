

-	**QueryType** is a synchronous unit of program, a pull-based signal node.
-	**TaskType** is an asynchronous unit of program, a push-based signal node.

Queries all returns immediately. It uses only currently available data and does not
wait for new signals. 

In contrast, tasks always waits for new signals, and route then into observers. 
Cancellation or progress signaling is fully up to implementations of each tasks. 
There's no unified way of them because everything require different approach on such
stuffs. Then cancellation or progress must be sent as a part of signal.

A task instance can be stateful. Actually they usually do due to impure nature of
I/O. Being stateful is the only way to process those uncertainity. Cancellation also
needs impure output from input. 

