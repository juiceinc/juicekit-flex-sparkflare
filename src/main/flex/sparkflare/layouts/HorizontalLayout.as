package sparkflare.layouts
{
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Sort;
	
	import sparkflare.mappers.MapperBase;
	
	/**
	 * Layouts are IMappers that affect multiple properties at once, typically
	 * x, y, height, and width. Horizontalayout lays items out in horizontally
	 */
	[Bindable]
	public class HorizontalLayout extends MapperBase
	{
		
		public var gap:Number = 0; 
		
		public var animateInitialLayout:Boolean = false;
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
			var _t:Transitioner;
			
			if (enabled) 
			{
				_t = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;
				
				if (items) 
				{
					var x:Number = 0;
					
					if (sortBy && sortBy.length > 0)
					{
						Sort.sortArrayCollectionBy(items, sortBy);
					}
					
					
					for each (row in items) 
					{
						// A proxy for the object's values after the 
						// transition has run.
						var postTransitionObject:Object = _t.$(row);
						_t.setValue(row, 'x', x);
						_t.setValue(row, 'y', 0);
						x += postTransitionObject.width + gap;
					}
				}

				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function HorizontalLayout()
		{
		}
		
		
	}
}