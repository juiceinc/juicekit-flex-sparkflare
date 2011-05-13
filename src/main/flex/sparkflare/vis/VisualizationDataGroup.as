package sparkflare.vis
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.controls.Alert;
	import mx.core.IDataRenderer;
	import mx.core.ILayoutElement;
	import mx.core.IVisualElement;
	import mx.events.CollectionEvent;
	import mx.events.FlexEvent;
	
	import org.juicekit.animate.TransitionEvent;
	import org.juicekit.animate.Transitioner;
	import org.juicekit.animate.Tween;
	import org.juicekit.util.FPSLabel;
	
	import spark.components.DataGroup;
	import spark.components.IItemRenderer;
	import spark.events.RendererExistenceEvent;
	import spark.layouts.supportClasses.LayoutBase;
	
	import sparkflare.mappers.MapperBase;
	import sparkflare.mappers.MapperChain;
	
	[DefaultProperty("mappers")] 
	
	/**
	 * A Visualization is an extension of a DataGroup with
	 * explicit rules that define how the item renderers are displayed
	 */
	public class VisualizationDataGroup extends DataGroup implements IVisualization
	{
		/** Storage for the mappers */
		private var _mappers:MapperChain;		
		/** Storage for the distortions */
		private var _distortions:MapperChain;		
		/** Storage for the transition's transitionPeriod in seconds */
		private var _transitionPeriod:Number = 1.5;
		
		
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
				_mappers.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
			} 
			_mappers = value;
			_mappers.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
		}
		
		
		/**
		 * A MapperChain to that operates on elements in the 
		 * <code>VisualizationDataGroup</code>.
		 */
		public function get distortions():MapperChain
		{
			return _distortions;
		}
		
		
		public function set distortions(value:MapperChain):void
		{
			value.owner = this;
			if (_distortions) {
				_distortions.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
			} 
			_distortions = value;
			_distortions.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
		}
		
		
		/**
		 * Run the mapper chain to update the visualization.
		 */
		protected function runVisualizationDistort(e:Event=null):void {
			if (_distortions != null && _distortions.length > 0) {
				// Run the operator list			
				var elements:ArrayCollection = new ArrayCollection();
				var element:IVisualElement;
				
				// Gather the elements that will be updated
				var count:int = this.numElements;
				
				for (var i:int = 0; i < count; i++)
				{
					// get the current element, we're going to work with the
					// ILayoutElement interface
					element = this.getElementAt(i);
					// If the layout is virtual and the element is not in 
					// view, element will be null
					if (element && element.includeInLayout) 
						elements.addItem(element);
				}
				
				//trace('distorting', e.type);
				// Calculate new values based on the mapper chain.
				distortions.distort(elements, e);
			}
		}
		
		
		
		/**
		 * Run the mapper chain.
		 */
		override protected function commitProperties():void {
			super.commitProperties();
			
			runVisualizationOperate();
		}
		
		
		/**
		 * A flag that indicates if mapper if encoding changes
		 * caused by a data update to ItemRenderers. This is often
		 * caused by scrolling in a virtual layout.  
		 */
		protected var runningDataUpdateTransition:Boolean = false;
		
		/**
		 * A Flag that indicates if transitions should run when 
		 * ItemRenderer data changes. Should be false if using a virtual layout,
		 * true otherwise.
		 * 
		 */
		public var runDataUpdateTransitions:Boolean = false;
		
		
		/**
		 * Run the mapper chain to update the visualization.
		 */
		protected function runVisualizationOperate():void {
			var t:Transitioner;
			
			if (runDataUpdateTransitions && runningDataUpdateTransition) 
			{
				t = Transitioner.DEFAULT;
			}
			else
			{
				if (transitioner) 
				{
					transitioner.stop();
					transitioner.dispose();
//					transitioner.reset();
					transitioner = null;					
				}
//				if (!transitioner)
					transitioner = new Transitioner(transitionPeriod, null);
				transitioner.optimize = true;
				t = transitioner;
			}
			
			
			// Run the operator list			
			var elements:ArrayCollection = new ArrayCollection();
			var element:IVisualElement;
			
			// Gather the elements that will be updated
			var count:int = this.numElements;
			
			for (var i:int = 0; i < count; i++)
			{
				// get the current element, we're going to work with the
				// ILayoutElement interface
				element = this.getElementAt(i);
				// If the layout is virtual and the element is not in 
				// view, element will be null
				if (element && element.includeInLayout) 
					elements.addItem(element);
			}
			
			// Calculate new values based on the mapper chain.
			if (mappers != null) 
			{
				mappers.operate(elements, transitioner);
				// Play the new values.
				transitioner.play();
			}
			runningDataUpdateTransition = false;
		}
		
		
		/**
		 * Called if the dataProvider or mapper has had changes. Recalculate the visualization.
		 */
		protected function dataUpdated(e:Event=null):void {
			invalidateProperties();
		}
		
		/** 
		 * @inheritDoc 
		 **/
		override public function set dataProvider(value:IList):void {
			if (dataProvider)
				dataProvider.removeEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
			super.dataProvider = value;
			if (value)
				dataProvider.addEventListener(CollectionEvent.COLLECTION_CHANGE, dataUpdated);
		}
		
		/**
		 * Perform an immediate update if data in the renderers change. This is often
		 * caused by a virtual layout reusing renderers. The mapper chain must be run with
		 * zero transition delay to get the right values in the renderers.
		 */
		protected function handleRendererDataChange(event:FlexEvent):void {
			if (!runningDataUpdateTransition) {
				this.invalidateProperties();
				runningDataUpdateTransition = true;
			}
		}
		
		
		/**
		 * When renderers are added, we need to listen for data changes. 
		 */
		protected function rendererAddDataChangedHandler(event:RendererExistenceEvent):void {
			event.renderer.addEventListener(FlexEvent.DATA_CHANGE, handleRendererDataChange);
		}
		
		
		/**
		 * Constructor
		 */
		public function VisualizationDataGroup()
		{
			// Add and remove listeners for data changes on renderers to handle virtual layouts.			
			this.addEventListener(RendererExistenceEvent.RENDERER_ADD, rendererAddDataChangedHandler);
			this.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, function(event:RendererExistenceEvent):void {
				event.renderer.removeEventListener(FlexEvent.DATA_CHANGE, handleRendererDataChange);
			});
			this.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void {
				runVisualizationDistort(e);
			});
			this.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void {
				runVisualizationDistort(e);
			});
			this.addEventListener(MouseEvent.MOUSE_MOVE, function(e:Event):void {
				runVisualizationDistort(e);
			});
			this.addEventListener(MouseEvent.ROLL_OUT, function(e:Event):void {
				runVisualizationDistort(e);
			});
		}
	}
}