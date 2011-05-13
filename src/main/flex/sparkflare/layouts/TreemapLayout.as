package sparkflare.layouts
{
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Property;
	import org.juicekit.util.Sort;
	import org.juicekit.util.Strings;
	
	import sparkflare.mappers.IMapper;
	import sparkflare.mappers.MapperBase;
	
	
	/**
	 * Layouts are IMappers that affect multiple properties at once, typically
	 * x, y, height, and width. TreemapLayout applies the squarify treemap
	 * algorithm to mapped items.
	 */
	[Bindable]
	public class TreemapLayout extends MapperBase
	{
		
		/**
		 * Storage for the property used to calculate treemap node size.
		 */
		protected var sizeProp:Property = Property.$("size");
		
		protected var _t:Transitioner = Transitioner.DEFAULT;
		
		/** Storage for getWorstPersistent calculations */
		private var _minArea:Number = Number.MAX_VALUE;
		private var _maxArea:Number = Number.MIN_VALUE;
		private var _totalArea:Number = 0;
		private var _wSquared:Number = 0;
		
		/**
		 * Pixels per unit of the sizeField
		 */
		private var pixelsPerSizeUnit:Number = 1;
		
		private var _row:Array = new Array();
		
		/** 
		 * The property from which to access size values for leaf nodes. 
		 **/
		public function get sizeField():String {
			return sizeProp.name;
		}
		
		public function set sizeField(s:String):void {
			sizeProp = Property.$(s);
		}
		
		
		/**
		 * @param c All items to operate on
		 * @param row A row to fill in
		 * @param w 
		 * @param r the size to fill
		 */
		private function squarify(items:Array, workingRow:Array, w:Number, r:Rectangle, visualElementProperty:String):void
		{
			var starttime:Number = getTimer();
			var worst:Number = Number.MAX_VALUE, nworst:Number;
			var len:int;
			var item:Object;
			var sz:Number;
			
			resetGetWorstPersistent(w);
			items.sort(Sort.$(sizeProp.name));
			
			// add up the total area, only including positive sizes.
			var tot:Number = 0;
			for each (item in items) 
			{
				sz = sizeProp.getValue(item);
				tot += sz > 0 ? sz : 0;
			}
			
			pixelsPerSizeUnit = r.height * r.width / tot;			
			
			// While there are items remaining
			while ((len = items.length) > 0) 
			{
				// add item to the row list, ignore if negative area
				item = items[len - 1];
				
				sz = sizeProp.getValue(item);
				
				// CG: if the area is invalid, don't put on layout list
				if (sz <= 0.0 || isNaN(sz)) {
					//TODO: determine if it is necessary to create a transitioner for this item
					items.pop();
					
					// TODO: set size to zero?
					continue;
				}
				
				workingRow.push(item);
				
				// CG: determine whether to keep popping items
				nworst = getWorstPersistent(workingRow, w);
				if (nworst <= worst) {
					items.pop();
					worst = nworst;
				} else {
					workingRow.pop(); // remove the latest addition
					r = layoutRow(workingRow, w, r, visualElementProperty); // layout the current row
					w = Math.min(r.width, r.height); // recompute w
					
					workingRow.splice(0, workingRow.length); // clear the row
					resetGetWorstPersistent(w);
					worst = Number.MAX_VALUE;
				}
			}
			
			if (workingRow.length > 0) {
				r = layoutRow(workingRow, w, r, visualElementProperty); // layout the current row
				workingRow.splice(0, workingRow.length); // clear the row
			}
			trace('Layout in ', getTimer() - starttime, 'ms');
		}
		
		
		/** 
		 * Reset getWorstPersistent calculations to initial values.
		 */
		private function resetGetWorstPersistent(w:Number):void {
			_minArea = Number.MAX_VALUE;
			_maxArea = Number.MIN_VALUE;
			_totalArea = 0;
			_wSquared = w * w;
		}
		
		
		/**
		 * Note: workingRow must contain items
		 */
		private function getWorstPersistent(workingRow:Array, w:Number):Number
		{
			// add up the total area
			var item:Object = workingRow[workingRow.length - 1];
			var sz:Number = sizeProp.getValue(item) * this.pixelsPerSizeUnit;
			sz = sz > 0 ? sz : 0;
			_minArea = Math.min(_minArea, sz);
			_maxArea = Math.max(_maxArea, sz);
			_totalArea += sz;
			
			var _totalAreaSquared:Number = _totalArea * _totalArea;
			return Math.max(_wSquared * _maxArea / _totalAreaSquared, _totalAreaSquared / (_wSquared * _minArea));
		}
		
		
		/**
		 * Layout a row
		 * 
		 * @param row an array of objects to layout
		 * @param ww the length of the minimal dimension
		 * @param r the rectangle
		 */
		private function layoutRow(row:Array, ww:Number, r:Rectangle, visualElementProperty:String):Rectangle
		{
			var item:Object;
			var s:Number = 0; // sum of row areas
			for each (item in row) {
				s += sizeProp.getValue(item) * pixelsPerSizeUnit;
			}
			
			var xx:Number = r.x, yy:Number = r.y, d:Number = 0;
			var hh:Number = ww == 0 ? 0 : s / ww;
			var horiz:Boolean = (ww == r.width);
			
			var visualElementProp:Property;
			if (visualElementProperty) 
				visualElementProp = Property.$(visualElementProperty)
			
			// set node positions and dimensions
			for each (item in row) {
				var nw:Number = pixelsPerSizeUnit * sizeProp.getValue(item) / hh;				
				if (visualElementProp) {
					item = visualElementProp.getValue(item);
				}
				var o:Object = _t.$(item);
				if (horiz) {
					o.x = xx + d;
					o.y = yy;
					o.width = nw;
					o.height = hh;
				} else {
					o.x = xx;
					o.y = yy + d;
					o.width = hh;
					o.height = nw;
				}
				d += nw;
			}
			
			// update space available in rectangle r
			if (horiz) {
				r.x = xx;
				r.y = yy + hh;
				r.height -= hh;
			} else {
				r.x = xx + hh;
				r.y = yy;
				r.width -= hh;
			}
			return r;
		}
		
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			var row:Object;
			var v:Number;
			
			if (enabled) 
			{
				var _t:Transitioner = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;
				
				var sizeProp:Property = Property.$(sizeField);
				
				if (items && items.length > 0) 
				{
					var typicalItem:Object = items[0];
					var visualElementProp:Property;
					if (visualElementProperty) 
						visualElementProp = Property.$(visualElementProperty)
					if (visualElementProp) {
						typicalItem = visualElementProp.getValue(typicalItem);
					}
					var r:Rectangle = new Rectangle(0, 0, typicalItem.owner.width, typicalItem.owner.height);
					var w:Number = Math.min(r.width, r.height);
					squarify(items.source.slice(), _row, w, r, visualElementProperty); 					
				}
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function TreemapLayout()
		{
		}		
		
	}
}