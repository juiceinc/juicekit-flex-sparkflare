package sparkflare.mappers
{  
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.utils.ObjectProxy;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Property;
	
	import sparkflare.mappers.MapperBase;
	
	
	
	/**
	 * Watches a collection selectedItems and sets property isSelected to ItemRenders
	 * with data found in the collection
	 */
	[Bindable]
	public class SelectionMapper extends MapperBase
	{
		/** Storage for selectedItems property */
		protected var _selectedItems:ArrayCollection = new ArrayCollection();
		
		/**
		 * A collection to watch 
		 */
		public function set selectedItems(v:ArrayCollection):void {
			_selectedItems.removeEventListener(CollectionEvent.COLLECTION_CHANGE, updateMapper);
			_selectedItems = v;
			_selectedItems.addEventListener(CollectionEvent.COLLECTION_CHANGE, updateMapper);
		}
		
		public function get selectedItems():ArrayCollection {
			return _selectedItems;
		}
		
		
		/**
		 * The property name to use for the selected boolean
		 * 
		 * @default 'isSelected'
		 */
		public var selectedField:String = 'isSelected';
		
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null):void
		{
			if (enabled) {
				if (items) {
					var selectedProp:Property = new Property(selectedField);
					
					for each (var row:Object in items) {
						if (row.hasOwnProperty('data')) 
							// TODO: possibly maintain a dictionary to use for lookups
							selectedProp.setValue(row, selectedItems.contains(row.data)); 
					}
					
				}					
			}
		}
		
		
		
		
		
	} // end of class Encoder
}