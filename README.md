LoanShark is a flexible and high-performance object pooling utility, written in AS3. It is battle-hardened, fully unit tested and actively maintained.

HOW TO USE IT

Especially useful with custom classes that are heavy to construct, simply instaniate a LoanShark instance, passing in your class of choice. You can then borrowObject and returnObject at will, the LoanShark will manage the reuse and allocation of objects in an efficient manner - making lighter work for your garbage collector:

    import org.kissmyas.utils.loanshark.LoanShark;
    
    var pool:LoanShark = new LoanShark(SomeClass);
    var someInstance:SomeClass = pool.borrowObject();
    pool.returnObject(someInstance);

A bunch of other options are available. Just check out the code to find out how to do:

  * Pool size pre-allocation
  * Pruning the pool of unused objects and flushing the pool of all objects
  * Adding reset and dispose method calls on pooled objects
  * Maximum pool wastage prune triggering
  * Listening for events from the pool
  * Exception triggers with strict mode
