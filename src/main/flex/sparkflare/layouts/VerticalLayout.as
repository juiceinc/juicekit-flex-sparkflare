package sparkflare.layouts
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Sort;
	
	import sparkflare.mappers.MapperBase;
	
	/**
	 * Layouts are IMappers that affect multiple properties at once, typically
	 * x, y, height, and width. HorizontalStripeLayout lays items out in vertical
	 * stripes.
	 */
	[Bindable]
	public class VerticalLayout extends MapperBase
	{
		
		public var gap:Number = 0; 
		
		public var animateInitialLayout:Boolean = true;
		private var seenItems:Dictionary = new Dictionary();
		
		public var initialX:Number = 0;
		public var initialY:Number = 0;
		
		/**
		 * If non-null, sort items by these properties before operating
		 */
		public var sortBy:Array = null;
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			var row:Object;
			var v:Number;
			var isNewItem:Boolean;
			
			if (enabled) 
			{
				var _t:Transitioner = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;
				
				if (items) 
				{
					var y:Number = 0;
					
					if (sortBy && sortBy.length > 0)
					{
						Sort.sortArrayCollectionBy(items, sortBy);
					}
					
					for each (row in items) 
					{
						isNewItem = (seenItems[row.data] === undefined);
						if (isNewItem)
							seenItems[row.data] = 1;
						
						if (isNewItem && !animateInitialLayout) 
						{
							row.x = 0;
							row.y = y;
						}
						else 
						{
							_t.setValue(row, 'y', y);
							_t.setValue(row, 'x', 0);
						}
						
						// A proxy for the object's values after the 
						// transition has run.
						var postTransitionObject:Object = _t.$(row);
						y += postTransitionObject.height + gap;
					}
				}
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function VerticalLayout()
		{
		}
		
		
	}
}