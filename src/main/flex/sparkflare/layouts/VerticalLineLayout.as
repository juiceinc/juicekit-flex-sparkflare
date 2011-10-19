package sparkflare.layouts
{
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Property;
	import org.juicekit.util.Sort;
	
	import sparkflare.mappers.IMapper;
	import sparkflare.mappers.MapperBase;
	
	/**
	 * Layouts are IMappers that affect multiple properties at once, typically
	 * x, y, height, and width. VerticalLineLayout lays items out as vertical bars.
	 */
	[Bindable]
	public class VerticalLineLayout extends MapperBase
	{
		
		public var sizeField:String;
		
		
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
				
				if (items) 
				{
					var max:Number = 0;
					var ownerWidth:Number = NaN;
					var ownerHeight:Number = NaN;
					for each (row in items) 
					{
						v = Number(sizeProp.getValue(row));
						max = (v > max)?v:max;
						if (isNaN(ownerWidth)) {
							ownerHeight = row.owner.height;
							ownerWidth = row.owner.width;
						}
					}
					
					var x:Number = 0;
					var y:Number = 0;
					var height:Number = 0;
					var width:Number = ownerWidth/items.length;
					//	Sort.sortArrayCollectionBy(items, [sizeField]);
					for each (row in items) 
					{
						v = Number(sizeProp.getValue(row));
						v = v > 0 ? v : 0;
						height = (v / max) * ownerHeight;
						y = ownerHeight - height;
						
						_t.setValue(row, 'height', height);
						_t.setValue(row, 'width', width);
						_t.setValue(row, 'x', x);
						_t.setValue(row, 'y', y);
						
						x += width;
					}
				}
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function VerticalLineLayout()
		{
		}
		
		
	}
}