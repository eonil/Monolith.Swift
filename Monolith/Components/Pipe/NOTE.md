

-	**QueryType** is a synchronous unit of program, a pull-based signal node.
-	**TaskType** is an asynchronous unit of program, a push-based signal node.

Queries all returns immediately. It uses only currently available data and does not
wait for new signals. 

In contrast, tasks always waits for new signals, and route then into observers. 
Cancellation or progress signaling is fully up to implementations of each tasks. 
There's no unified way of them because everything require different approach on such
stuffs.

Because queries return immediately, there's no need to separate classes and instances
of the processing, but tasks need strict separation. Single instance of a task performs
single operation, and all signals must be arrived in correct order.