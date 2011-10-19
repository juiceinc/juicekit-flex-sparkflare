package sparkflare.mappers
{
	import flash.errors.IllegalOperationError;
	
	import mx.collections.ArrayCollection;
	import mx.collections.ListCollectionView;
	
	import org.juicekit.animate.Transitioner;
	
	/**
	 * An ArrayCollection of IMapper items. A <code>MapperSwitch</code> evaluates
	 * only the IMapper at <code>selectedIndex</code>.
	 * 
	 */
	[Bindable]
	public class MapperSwitch extends MapperChain
	{		
		
		/**
		 * The selected mapper, based on <code>selectedIndex</code>.
		 */
		public function get selectedItem():IMapper {
			if (this.list.length > selectedIndex) {
				return this.list.getItemAt(selectedIndex) as IMapper;
			}
			return null;
		}
		
		/**
		 * The IMapper to evaluate when <code>operate</code> is called.
		 */
		public var selectedIndex:int = 0;
		
		
		/**
		 * Performs an operation over the contents of a visualization.
		 * @param t a Transitioner instance for collecting value updates.
		 */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void {
			if (enabled) {
				if (selectedItem) {
					selectedItem.operate(items, t, visualElementProperty, doImmediate || immediate);	
				}
			}
		}
		
		
		/**
		 * Constructor
		 */
		public function MapperSwitch()
		{
			super();
		}
	}
}