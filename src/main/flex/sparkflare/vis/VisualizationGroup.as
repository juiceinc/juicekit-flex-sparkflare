package sparkflare.vis
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.core.IDataRenderer;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	import mx.graphics.SolidColor;
	
	import org.juicekit.animate.TransitionEvent;
	import org.juicekit.animate.Transitioner;
	import org.juicekit.animate.Tween;
	import org.juicekit.util.FPSLabel;
	
	import spark.components.DataGroup;
	import spark.components.Group;
	import spark.components.IItemRenderer;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.supportClasses.LayoutBase;
	import spark.primitives.Rect;
	
	import sparkflare.mappers.MapperBase;
	import sparkflare.mappers.MapperChain;
	
	[DefaultProperty("mappers")] 
	
	/**
	 * A Visualization is an extension of a Group with
	 * explicit rules that define how the item renderers are displayed
	 */
	public class VisualizationGroup extends Group implements IVisualization
	{
		/** Storage for the mappers */
		private var _mappers:MapperChain;		
		/** Storage for the transition's transitionPeriod in seconds */
		private var _transitionPeriod:Number = 1.0;
		
		
		/**
		 * The transitioner that plays changes in properties.
		 */
		public var transitioner:Transitioner = new Transitioner(transitionPeriod);
		
		
		/**
		 * The time it takes for a transition to play in seconds.
		 */
		public function get transitionPeriod():Number
		{
			return _transitionPeriod;
		}
		
		
		public function set transitionPeriod(value:Number):void
		{
			transitioner.duration = value;
			_transitionPeriod = value;
		}
		
		/**
		 * A MapperChain to that operates on elements in the 
		 * <code>VisualizationDataGroup</code>.
		 */
		public function get mappers():MapperChain
		{
			return _mappers;
		}
		
		
		public function set mappers(value:MapperChain):void
		{
			value.owner = this;
			if (_mappers) {
				_mappers.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
			} 
			_mappers = value;
			_mappers.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
		}
		
		
		/**
		 * Run the mapper chain.
		 */
		override protected function commitProperties():void {
			super.commitProperties();			
			runVisualizationOperate();
		}
		
		
		protected var visNodes:ArrayCollection = new ArrayCollection();
		
		private function doUpdate(e:Event):void {
			this.invalidateDisplayList();
			
			trace('invalidate display list', this.getElementAt(0).width);
		}
        
		/**
		 * Run the mapper chain to update the visualization.
		 */
		protected function runVisualizationOperate():void {
			var t:Transitioner = transitioner;
			
			t.removeEventListener(TransitionEvent.STEP, doUpdate);
			// Pause and clear any running transition.
			t.stop();
			t.reset();
			// Calculate new values based on the mapper chain.
			trace('running vis', visNodes.length);
			mappers.operate(visNodes, t, "node");
			// Play the new values.
			t.addEventListener(TransitionEvent.STEP, doUpdate);
			t.play();
		}
		
		
		/**
		 * Called if the dataProvider or mapper has had changes. Recalculate the visualization.
		 */
		protected function dataUpdated(e:Event=null):void {
			invalidateProperties();
		}
		
		private var _dataProvider:IList;
        
        private var _renderer:Function;
        
        public function set renderer(f:Function):void {
            _renderer = f;
            this.dataProvider = _dataProvider;
        }
        
        public function get renderer():Function {
            return _renderer;
        }
		
		/** 
		 * @inheritDoc 
		 **/
		public function set dataProvider(value:IList):void {
			if (dataProvider)
				dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
			
            visNodes.removeAll();
			_dataProvider = value; 
			for each (var o:Object in value) {
                var r:*;
                var rend:Function = this.renderer;
                if (rend != null) {
                    r = rend();                    
                } else {
                    r = new Rect();
                    r.fill = new SolidColor(0xcccccc);
                } 
				//r.height = 20; r.width = 20;
				this.addElement(r);
				visNodes.addItem({node:r, data:o});
			}
			dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
		}
		
		public function get dataProvider():IList {
			return _dataProvider;
		}
		
		
		
		
		/**
		 * Constructor
		 */
		public function VisualizationGroup()
		{
		}
	}
}