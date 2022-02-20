LoanShark is a flexible and high-performance object pooling utility, written in AS3. It is battle-hardened, fully unit tested and actively maintained.

### PLEASE NOTE: This repo is no longer maintained. However, depsite the fact that Flash is long dead, the AS3 code here is actually useful since it is the most test-covered object pooling utility available and AS3 projects may still be built using the Harman AIR SDK for building mobile apps, or https://github.com/ruffle-rs/ruffle/ for websites/desktop.

# How to use it #

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

# Examples #

- Create a pool of Bitmaps, which all wrap the same BitmapData, by default

```
// Given any BitmapData
var bitmapData:BitmapData;

// Create a pool a Bitmap objects, with 'bitmapData' as the default init object
var pool:LoanShark = new LoanShark(Bitmap, false, 0, 0, bitmapData);

// You can get as many Bitmaps from the pool as necessary
var bitmap:Bitmap = pool.borrowObject();
addChild(bitmap);

// When done with it, recycle it back into the pool
pool.returnObject(removeChild(bitmap));
```
