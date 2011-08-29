package
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import org.kissmyas.utils.loanshark.LoanShark;
	import org.kissmyas.utils.loanshark.LoanSharkTest;
	
	/**
	 * Loan Shark object pooling utility demo
	 * @author Liam O'Donnell
	 * @version 1.0
	 * @usage This demo simply runs the unit tests for the pooling utility and shows one usage example
	 * @see http://www.spikything.com/blog/?s=objectpool for info/updates
	 * This software is released under the MIT License <http://www.opensource.org/licenses/mit-license.php>
	 * © 2011 spikything.com
	 */
	[SWF(frameRate="60", width="590", height="420", backgroundColor="#808080")]
	public class Main extends Sprite
	{
		private var bitmapPool :LoanShark;
		
		public function Main():void
		{
			LoanSharkTest.runUnitTests();
			
			if (stage)
				init();
			else
				addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// Create a BitmapData which will be used in all Bitmap instances
			var bitmapData:BitmapData = new BitmapData(75, 75, false);
			bitmapData.noise(0);
			
			// Create a pool of Bitmaps, not in strict mode, with a pre-allocated size of 10, where bitmapData is passed to the constructor of each Bitmap
			bitmapPool = new LoanShark(Bitmap, false, 10, 0, bitmapData);
			
			addEventListener(Event.ENTER_FRAME, update);
		}
		
		private function update(e:Event):void
		{
			// Add or remove some Bitmaps to/from the stage
			var i:int = 20;
			while (--i)
				addOrRemoveItem();
			
			// Clear all display objects from the stage
			if (Math.random() > .99)
				removeAllChildren();
			
			// Prune the pool of unused objects
			if (Math.random() > .99)
				bitmapPool.clean();
			
			trace('Pool size = ' + bitmapPool.size + ' (' + bitmapPool.used + ' in use)');
		}
		
		private function addOrRemoveItem():void
		{
			if (Math.random() > .5)
			{
				addBitmap();
			}
			else
			{
				recycleBitmap();
			}
		}
		
		private function addBitmap():void
		{
			var bitmap:Bitmap = bitmapPool.borrowObject();
			bitmap.x = Math.random() * (stage.stageWidth - bitmap.width);
			bitmap.y = Math.random() * (stage.stageHeight - bitmap.height);
			addChild(bitmap);
		}
		
		private function removeAllChildren():void
		{
			trace('Recycling all children...');
			
			while (numChildren)
				recycleBitmap();
		}
		
		private function recycleBitmap():void
		{
			if (numChildren)
				bitmapPool.returnObject( removeChildAt(0) );
		}
		
	}
	
}
