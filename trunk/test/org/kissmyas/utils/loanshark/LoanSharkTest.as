package org.kissmyas.utils.loanshark
{
    import flash.events.Event;
    import org.flexunit.Assert;
	
	/**
	 * Loan Shark unit tests
	 * @author Liam O'Donnell
	 * @version 1.0
	 * @usage Run with FlexUnit or call the static method 'runUnitTests' for standalone testing
	 * @see http://www.spikything.com/blog/?s=LoanShark for info/updates
	 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	 * © 2011 spikything.com
	 */
    public class LoanSharkTest
    {
        private var _sut :LoanShark;
        private var _cleaned :Boolean;
        private var _flushed :Boolean;
        private var _disposed :Boolean;
		
        [Test(description="LoanShark.getObject() should return an instance of the ObjectClass:Class that was passed to its constructor")]
        public function getObjectFromPool():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);
			
            //then
			Assert.assertStrictlyEquals(TestObject, sut.ObjectClass);
            Assert.assertTrue("LoanShark.getObject() did not return the correct object type", sut.borrowObject() is TestObject);
        }

        [Test(description="LoanShark should create as many objects as are checked-out from the pool at any one time")]
        public function createMultiple():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);
            var objectCount:uint = 3;

            //when
            for (var i:uint = 0; i < objectCount; i++)
                sut.borrowObject();

            //then
            Assert.assertTrue("LoanShark did not grow to the correct size with multiple calls of getObject()", sut.size == objectCount);
        }

        [Test(description="LoanShark should grow only when necessary, not when reusing objects from a large enough pool")]
        public function checkOutCheckInAvailability():void
        {
            //given
            var poolIntialSize:uint = 1;
            var sut:LoanShark = new LoanShark(TestObject, false, poolIntialSize);
            var poolAvailable:int = sut.unused;

            //when
            for (var i:uint = 0; i < 10; i++)
                sut.returnObject(sut.borrowObject());

            //then
            Assert.assertTrue("LoanShark availability should not change when getting then putting objects one at a time from a large pool",
                              sut.unused == poolAvailable);
            Assert.assertTrue("LoanShark size should not change unless getObject is called on a pool with 0 availability", sut.size == poolIntialSize);
        }

        [Test(description="LoanShark.unused should correctly increase and decrease to match the availability count of pooled objects")]
        public function preallocatedPoolSize():void
        {
            //given
            var poolIntialSize:uint = 10;
            var sut:LoanShark = new LoanShark(TestObject, false, poolIntialSize);

            //when
            var testObject:TestObject;
            for (var i:uint = 0; i < poolIntialSize; i++)
                testObject = sut.borrowObject();

            //then
            Assert.assertTrue("LoanShark of " + poolIntialSize + " objects should have no availability left if we get " + poolIntialSize + " objects from it", sut.unused == 0);

            //when
            sut.returnObject(testObject);

            //then
            Assert.assertTrue("LoanShark size shold not change when simply returning objects to the pool", sut.size == poolIntialSize);
            Assert.assertTrue("LoanShark availability should increment each time we return an object to the pool", sut.unused == 1);
        }
		
        [Test(description="LoanShark should grow as necessary and shrink when appropriate if maxBuffer has been set")]
        public function unusedPoolAfterCheckOut():void
        {
            //given
            var objectCount:int = 5;
            var overflow:int = 1;
            var expectedFinalSize:int = 0;
            var sut:LoanShark = new LoanShark(TestObject, false, 0, objectCount);
            var objects:Vector.<TestObject> = new Vector.<TestObject>;
            var testObject:TestObject;
            var i:uint;
			
            //when
            for (i = 0; i < objectCount; i++)
            {
                testObject = sut.borrowObject();
                objects.push(testObject);
            }

            //then
            Assert.assertTrue("LoanShark did not grow to the expected size of " + objectCount, sut.size == objectCount);

            //when
            for (i = 0; i < overflow; i++)
            {
                testObject = sut.borrowObject();
                objects.push(testObject);
            }

            while (objects.length)
                sut.returnObject(objects.pop());

            //then
            Assert.assertTrue("LoanShark should empty if availability increases beyond maxUnused, size = " + sut.size, sut.size == expectedFinalSize);
            Assert.assertTrue("LoanShark should empty if availability increases beyond maxUnused, unused = " + sut.unused, sut.unused == expectedFinalSize);
        }

        [Test(description="LoanShark should pass the initObject (if any) to the constructor of pooled objects it creates")]
        public function objectInitialisation():void
        {
            //given
            var initObject:TestObject = new TestObject;
            var sut:LoanShark = new LoanShark(ParameteredConstructorObject, false, 0, 0, initObject);

            //when
            var item:ParameteredConstructorObject = sut.borrowObject();

            //then
            Assert.assertTrue("LoanShark did not pass the correct initialisation object to the constructor of a pooled class.", item.initObject == initObject);
        }

        [Test(description="LoanShark should reuse objects instances, where possible")]
        public function identicalObject():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);
            var firstItem:TestObject = sut.borrowObject();
            var nextItem:TestObject;

            //when
            sut.returnObject(firstItem);
            nextItem = sut.borrowObject();

            //then
            Assert.assertTrue("LoanShark did not return a reused instance where appropriate.", firstItem == nextItem);
        }

        [Test(description="LoanShark should ignore when object returned to a pool with no checked-out objects.")]
        public function multipleCheckInResilience():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);
            var testObject:TestObject = sut.borrowObject();

            //when
			sut.returnObject(testObject);
			sut.returnObject(testObject);

            //then
            if (sut.unused == 0)
            {
                Assert.fail("LoanShark availability did not grow when returning an object to the pool.");
            }
            else if (sut.unused > 1)
            {
                Assert.fail("LoanShark grew too large when returning the same object to the pool twice.");
            }
        }
		
		[Test(description="The error IDs for each type of error should be unique.")]
		public function uniqueErrorIDs():void
		{
			var failMessage:String = 'Error IDs should be unique';
			Assert.assertFalse(failMessage, LoanShark.ERROR_CHECK_IN_TYPE == LoanShark.ERROR_MULTI_CHECK_IN);
			Assert.assertFalse(failMessage, LoanShark.ERROR_CHECK_IN_TYPE == LoanShark.ERROR_NULL_CHECK_IN);
			Assert.assertFalse(failMessage, LoanShark.ERROR_CHECK_IN_TYPE == LoanShark.ERROR_RECYCLE_UNUSED);
			Assert.assertFalse(failMessage, LoanShark.ERROR_MULTI_CHECK_IN == LoanShark.ERROR_RECYCLE_UNUSED);
			Assert.assertFalse(failMessage, LoanShark.ERROR_MULTI_CHECK_IN == LoanShark.ERROR_NULL_CHECK_IN);
			Assert.assertFalse(failMessage, LoanShark.ERROR_NULL_CHECK_IN == LoanShark.ERROR_RECYCLE_UNUSED);
		}
		
        [Test(description="LoanShark should throw an error when object returned to a pool with no checked-out objects in strict mode.")]
        public function strictMode_checkIn_whenNo_checkOuts():void
        {
            //given
			var strictMode:Boolean = true;
            var sut:LoanShark = new LoanShark(TestObject, strictMode);
            var testObject:TestObject = sut.borrowObject();
			var errorThrown:Boolean = false;
			
            //when
			sut.returnObject(testObject);
			
			try
			{
				sut.returnObject(testObject);
			}
			catch (e:Error)
			{
				Assert.assertEquals(LoanShark.ERROR_RECYCLE_UNUSED, e.errorID);
				errorThrown = true;
			}

            //then
            if (sut.unused == 0)
            {
                Assert.fail("LoanShark availability did not grow when returning an object to the pool.");
            }
            else if (sut.unused > 1)
            {
                Assert.fail("LoanShark grew too large when returning the same object to the pool twice.");
            }
			Assert.assertTrue("Expected Error was not thrown", errorThrown);
        }
		
        [Test(description="LoanShark should throw an error when same object returned to pool more than once in strict mode.")]
        public function strictMode_GetOnce_PutMultiple():void
        {
            //given
			var strictMode:Boolean = true;
            var sut:LoanShark = new LoanShark(TestObject, strictMode);
			
			sut.borrowObject();
            var testObject:TestObject = sut.borrowObject();
			sut.returnObject(testObject);
			
            //when
			var errorThrown:Boolean = false;
			try
			{
				sut.returnObject(testObject);
			}
			catch (e:Error)
			{
				errorThrown = true;
			}
			
            //then
			Assert.assertTrue("Expected Error was not thrown on returning the same object to the pool twice", errorThrown);
        }
		
        [Test(description="LoanShark should now throw an error when an object is checked out and straight back into a pool with initial size > 0")]
        public function strictMode_InitialSize_GetPutCheck():void
        {
            //given
			var strictMode:Boolean = true;
			var initialPoolSize:uint = 10;
            var sut:LoanShark = new LoanShark(TestObject, strictMode, initialPoolSize);
			
			//when
            var testObject:TestObject = sut.borrowObject();
			sut.returnObject(testObject);
        }
		
        [Test(description="LoanShark should empty and become unusable, ready for destruction after LoanShark.dispose() is called")]
        public function objectDisposal():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject, false, 10);

            //when
            sut.borrowObject();
            try
            {
                sut.dispose();
            }
            catch (e:Error)
            {
                Assert.fail('LoanShark.dispose() failed.' + e.message);
            }

            //then
            Assert.assertTrue("LoanShark did not dispose correctly.", sut.size == 0);

            //when
            var useAfterDisposeFailed:Boolean = false;
            try
            {
                sut.borrowObject();
            }
            catch (e:Error)
            {
                useAfterDisposeFailed = true;
            }

            //then
            Assert.assertTrue("LoanShark was still usable after disposal.", useAfterDisposeFailed);
        }

        [Test(description="LoanShark.used should return the correct count of objects checked out of the pool")]
        public function poolUsage():void
        {
            //given
            var initialSize:int = 10;
            var useCount:int = 5;
            var sut:LoanShark = new LoanShark(TestObject, false, initialSize);

            //when
            for (var i:int = 0; i < useCount; i++)
                sut.borrowObject();

            //then
            Assert.assertTrue("LoanShark did not report correct usage size" + sut.used, sut.used == useCount);
        }

        [Test(description="LoanShark.clean() should remove all unused objects from the pool")]
        public function poolPrune():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject, false, 10);

            //when
            sut.clean();

            //then
            Assert.assertTrue("LoanShark did not clean of unused objects.", sut.size == 0);
        }

        [Test(description="LoanShark.flush() should remove all objects from the pool, if none are checked out")]
        public function poolFlush():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject, false, 10);

            //when
            sut.flush();

            //then
            Assert.assertTrue("LoanShark did not flush objects.", sut.size == 0);
        }

        [Test(description="LoanShark.flush() should not remove any objects from the pool if any are checked out")]
        public function inUsePoolFlush():void
        {
            //given
            var initialSize:int = 10;
            var sut:LoanShark = new LoanShark(TestObject, false, initialSize);
			sut.addEventListener(LoanShark.EVENT_FLUSHED, onFlush, false, 0, true);
			
            //when
			_flushed = false;
            sut.borrowObject();
            sut.flush();

            //then
            Assert.assertTrue("LoanShark flushed in-use objects without being 'forced'.", sut.size == initialSize);
			Assert.assertFalse("LoanShark dispatched its FLUSH Event when it should have skipped flushing a pool with checked-out items.", _flushed);
			sut.removeEventListener(LoanShark.EVENT_FLUSHED, onFlush);
        }

        [Test(description="LoanShark.flush(true) should remove all objects from the pool, even if objects are still checked out")]
        public function forcedFlush():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject, false, 10);

            //when
            sut.borrowObject();
            sut.flush(true);

            //then
            Assert.assertTrue("LoanShark did not flush in-use objects when 'forced'.", sut.size == 0);
        }

        [Test(description="LoanShark should ignore attempts to return null objects to the pool")]
        public function nullCheckIn():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);

            //when
            sut.returnObject(null);

            //then
            Assert.assertTrue("LoanShark grew when returning a null object reference to the pool.", sut.size == 0);
        }
		
        [Test(description="LoanShark should ignore attempts to return the wrong type of object to the pool.")]
        public function incorrectObjectType():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);

            //when
            sut.returnObject(new String);

            //then
            Assert.assertTrue("LoanShark grew when returning a null object reference to the pool.", sut.size == 0);
        }
		
        [Test(description="LoanShark should throw an error when attempting to check in invalid objects to the pool in strict mode.")]
        public function strictMode_null_checkIn():void
        {
            //given
			var strictMode:Boolean = true;
            var sut:LoanShark = new LoanShark(TestObject, strictMode);
			var errorThrown:Boolean = false;
			
            //when
			try
			{
				sut.returnObject(null);
			}
			catch (e:Error)
			{
				errorThrown = true;
			}
			
            //then
            Assert.assertTrue("LoanShark grew when returning a null object reference to the pool.", sut.size == 0);
			Assert.assertTrue("Expected Error was not thrown", errorThrown);
        }
		
        [Test(description="LoanShark should throw an error when attempting to return the wrong type of object to the pool in strict mode.")]
        public function strictMode_Wrong_Object_Type():void
        {
            //given
			var strictMode:Boolean = true;
            var sut:LoanShark = new LoanShark(TestObject, strictMode);
			var errorThrown:Boolean = false;
			
            //when
			try
			{
				sut.returnObject(new String);
			}
			catch (e:Error)
			{
				errorThrown = true;
			}

            //then
            Assert.assertTrue("LoanShark grew when returning a null object reference to the pool.", sut.size == 0);
			Assert.assertTrue("Expected Error was not thrown", errorThrown);
        }
		
		[Test(description="The event types should be unique.")]
		public function uniqueEventTypes():void
		{
			var failMessage:String = 'Event types must have unique names';
			Assert.assertFalse(failMessage, LoanShark.EVENT_CLEANED == LoanShark.EVENT_DISPOSED);
			Assert.assertFalse(failMessage, LoanShark.EVENT_DISPOSED == LoanShark.EVENT_FLUSHED);
			Assert.assertFalse(failMessage, LoanShark.EVENT_CLEANED == LoanShark.EVENT_FLUSHED);
		}
		
        [Test(description="LoanShark should dispatch events of the type CLEANED, FLUSHED and DISPOSED when clean(), flush() and dispose() are called")]
        public function eventDispatch():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject);
            sut.addEventListener(LoanShark.EVENT_CLEANED, onClean, false, 0, true);
            sut.addEventListener(LoanShark.EVENT_FLUSHED, onFlush, false, 0, true);
            sut.addEventListener(LoanShark.EVENT_DISPOSED, onDispose, false, 0, true);
			
            //when
            _cleaned = false;
            sut.clean();

            //then
            Assert.assertTrue("LoanShark did not dispatch CLEAN event when cleaned.", _cleaned);
            sut.removeEventListener(LoanShark.EVENT_CLEANED, onClean);

            //when
            _flushed = false;
            sut.flush();

            //then
            Assert.assertTrue("LoanShark did not dispatch FLUSH event when flushed.", _flushed);
            sut.removeEventListener(LoanShark.EVENT_FLUSHED, onFlush);

            //when
            _disposed = false;
            sut.dispose();

            //then
            Assert.assertTrue("LoanShark did not dispatch DISPOSE event when disposed.", _disposed);
        }

        [Test(description="LoanShark should call a pooled object's reset method (if any) when recycling an object to the pool")]
        public function objectReset():void
        {
            //given
            var resetMethodName:String = 'reset';
            var sut:LoanShark = new LoanShark(TestObject, false, 0, 0, null, resetMethodName);
            var testObject:TestObject;

            //when
            testObject = sut.borrowObject();
            sut.returnObject(testObject);

            //then
            Assert.assertTrue("LoanShark did not reset an object on returning it to the pool.", testObject.isReset);
        }

        [Test(description="LoanShark should call a pooled object's dispose method (if any) when removing an object from the pool")]
        public function cleanupObjectDisposal():void
        {
            //given
            var disposeMethodName:String = 'dispose';
            var sut:LoanShark = new LoanShark(TestObject, false, 0, 0, null, '', disposeMethodName);
            var testObject:TestObject;

            //when
            testObject = sut.borrowObject();
            sut.returnObject(testObject);
            sut.clean();

            //then
            Assert.assertTrue("LoanShark did not call an object's dispose method when removing it from the pool.", testObject.isDisposed);
        }

        [Test(description="LoanShark should call a pooled object's dispose method (if any) when flushing with disposeUnusedObjects = true")]
        public function flushObjectDisposal():void
        {
            //given
            var disposeMethodName:String = 'dispose';
            var sut:LoanShark = new LoanShark(TestObject, false, 0, 0, null, '', disposeMethodName);
            var testObject:TestObject;

            //when
            testObject = sut.borrowObject();
            sut.returnObject(testObject);
            sut.flush(false, true);

            //then
            Assert.assertTrue("LoanShark did not call an unsed object's dispose method when flushing the pool with disposeUnusedObjects = true", testObject.isDisposed);
        }
		
        [Test(description="LoanShark should perform without throwing any errors under heavy abuse")]
        public function stressTest():void
        {
            //given
            var sut:LoanShark = new LoanShark(TestObject, false, 5, 5, null, 'reset', 'dispose');
            var stressIterations:int = 10000;
			
            //when
            var lastObject:TestObject = sut.borrowObject();
            for (var i:int = 0; i < stressIterations; i++)
            {
                //then
                try
                {
                    lastObject = sut.borrowObject();
                    if ((i % 17) == 0)
						for (var j:int = 0; j < (i % 21); j++)
							sut.returnObject(lastObject);
					
                    if ((i % 23) == 0)
						sut.clean();
					
                    if ((i % 31) == 0)
						sut.flush((i % 2) == 0, (i % 3) == 0);
                }
                catch (e:Error)
                {
                    Assert.fail("LoanShark threw an error during the stress test: " + e.message);
                }
            }
            sut.dispose();

            //then
            Assert.assertEquals("LoanShark did not empty correctly after stress test", 0, sut.size);
        }
		
		/**
		 * For standalone testing
		 */
		public static function runUnitTests():void
		{
			new LoanSharkTest().allTests();
		}
		
        public function allTests():void
        {
            getObjectFromPool();
            createMultiple();
            checkOutCheckInAvailability();
            preallocatedPoolSize();
            unusedPoolAfterCheckOut();
            objectInitialisation();
            identicalObject();
            objectDisposal();
            multipleCheckInResilience();
			uniqueErrorIDs();
			strictMode_checkIn_whenNo_checkOuts();
			strictMode_GetOnce_PutMultiple();
			strictMode_InitialSize_GetPutCheck();
            poolUsage();
            poolPrune();
            poolFlush();
            inUsePoolFlush();
            forcedFlush();
			incorrectObjectType();
			nullCheckIn();
			strictMode_null_checkIn();
			strictMode_Wrong_Object_Type();
			uniqueEventTypes();
            eventDispatch();
            objectReset();
            cleanupObjectDisposal();
            flushObjectDisposal();
            stressTest();
        }
		
        private function onFlush(e:Event = null):void
        {
            _flushed = true;
            if (e == null || !(e is Event))
                Assert.fail("LoanShark did not dispatch a correct event.");

            Assert.assertEquals("LoanShark dispatched the wrong event type", e.type, LoanShark.EVENT_FLUSHED);
        }
		
        private function onDispose(e:Event = null):void
        {
            _disposed = true;
            if (e == null || !(e is Event))
                Assert.fail("LoanShark did not dispatch a correct event.");

            Assert.assertEquals("LoanShark dispatched the wrong event type", e.type, LoanShark.EVENT_DISPOSED);
        }
		
        private function onClean(e:Event = null):void
        {
            _cleaned = true;
            if (e == null || !(e is Event))
                Assert.fail("LoanShark did not dispatch a correct event.");

            Assert.assertEquals("LoanShark dispatched the wrong event type", e.type, LoanShark.EVENT_CLEANED);
        }
		
    }
	
}

class TestObject
{
    public var isDisposed :Boolean;
    public var isReset :Boolean;
	public var id :String;
	
    public function TestObject()
    {
    }
	
    public function dispose():void
    {
        isDisposed = true;
    }
	
    public function reset():void
    {
        isReset = true;
    }
	
	public function toString():String
	{
		return id;
	}
}

class ParameteredConstructorObject
{
    public var initObject :TestObject;
	
    public function ParameteredConstructorObject(initObject:TestObject)
    {
        if (initObject != null)
            this.initObject = initObject;
    }
}
