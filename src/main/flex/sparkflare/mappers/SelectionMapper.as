package sparkflare.mappers
{  
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	import mx.utils.ObjectProxy;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.util.Property;
	
	import sparkflare.mappers.MapperBase;
	import sparkflare.util.ISelectionManager;
	import sparkflare.util.SelectionManager;
	
	
	
	/**
	 * Watches a collection selectedItems and sets property isSelected to ItemRenders
	 * with data found in the collection
	 */
	[Bindable]
	public class SelectionMapper extends MapperBase
	{


		private var _selectionManager:ISelectionManager;
		
		public function set selectionManager(v:ISelectionManager):void {
			_selectionManager = v;
			_selectionManager.addEventListener('selectionChanged', updateMapper);
		}
		
		public function get selectionManager():ISelectionManager {
			return _selectionManager;
		}
		

		/**
		 * The property name to use for the selected boolean
		 * 
		 * @default 'isSelected'
		 */
		public var selectedField:String = 'isSelected';
		
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			if (enabled) {
				if (items) {
					var selectedProp:Property = new Property(selectedField);
					
					for each (var row:Object in items) {
						selectedProp.setValue(row, selectionManager.isSelected(row.data));
					}
					
				}					
			}
		}
		
	}
}