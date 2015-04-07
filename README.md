Loan Shark is a flexible and high-performance object pooling utility, written in AS3. It is battle-hardened, fully unit tested and will be regularly updated.

==How to use it==

Especially useful with custom classes that a heavy to constructor, simply instaniate a LoanShark instance, passing in your class of choice. You can then borrowObject and returnObject at will, the LoanShark will manage reuse and allocation of objects - making lighter work for your garbage collector:

{{{
var pool:LoanShark = new LoanShark(SomeClass);
var someInstance:SomeClass = pool.borrowObject();
pool.returnObject(someInstance);
}}}

A bunch of other options are available, simply check out the code to find out how to do:

  * Pool size pre-allocation
  * Pruning the pool of unused objects and flushing the pool of all objects
  * Adding reset and dispose method calls on pooled objects
  * Maximum pool wastage prune triggering
  * Listening for events from the pool
  * Exception triggers with strict mode
