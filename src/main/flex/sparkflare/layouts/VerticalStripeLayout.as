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
	 * x, y, height, and width. HorizontalStripeLayout lays items out in vertical
	 * stripes.
	 */
	[Bindable]
	public class VerticalStripeLayout extends MapperBase
	{

		public var sizeField:String;
				
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null):void
		{
			var row:Object;
			var _t:Transitioner;
			var v:Number;
			
			if (enabled) 
			{
				_t = (t != null ? t : Transitioner.DEFAULT);
				var sizeProp:Property = Property.$(sizeField);

                
				if (items) 
				{

                    var visualElementProp:Property;
                    if (visualElementProperty) 
                        visualElementProp = Property.$(visualElementProperty)
                            
                    
                    var ttl:Number = 0;
					var ownerWidth:Number = NaN;
					var ownerHeight:Number = NaN;
					for each (row in items) 
					{
						v = Number(sizeProp.getValue(row));
						ttl += v > 0 ? v : 0;
						if (isNaN(ownerWidth)) {
                            if (visualElementProp) {
                                row = visualElementProp.getValue(row);
                            }
							ownerHeight = row.owner.height;
							ownerWidth = row.owner.width;
						}
					}
					
					var x:Number = 0;
					var y:Number = 0;
					var height:Number = ownerHeight;
					var width:Number = 0;
					var area:Number = ownerWidth * ownerHeight;
					Sort.sortArrayCollectionBy(items, [sizeField]);
					for each (row in items) 
					{
						v = Number(sizeProp.getValue(row));
						v = v > 0 ? v : 0;
						width = (v / ttl) * area / height;

                        if (visualElementProp) {
                            row = visualElementProp.getValue(row);
                        }
						_t.setValue(row, 'height', height);
						_t.setValue(row, 'width', width);
						_t.setValue(row, 'x', x);
						_t.setValue(row, 'y', y);
						
						x += width;
					}
				}
				
				_t = null;
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function VerticalStripeLayout()
		{
		}
		
		
	}
}