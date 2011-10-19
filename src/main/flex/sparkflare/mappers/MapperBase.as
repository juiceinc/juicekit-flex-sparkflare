package sparkflare.mappers
{

	import flash.events.Event;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.utils.NameUtil;
	import mx.utils.ObjectProxy;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.interfaces.IEvaluable;
	import org.juicekit.util.Filter;
	import org.juicekit.util.Property;
	
	import sparkflare.vis.VisualizationDataGroup;
	
	/**
	 * Mappers performs processing tasks on the contents of a VisualizationDataGroup.
	 * These tasks include layout, and color, shape, and size encoding.
	 * Custom operators can be defined by subclassing this class.
	 * 
	 * <p>This is a base class that should not be used directly.</p>
	 */
	public class MapperBase extends ObjectProxy implements IMapper
	{
		// -- Properties ------------------------------------------------------
		
		private var _name:String = NameUtil.createUniqueName(this);
		private var _filter:*;
		
		/** Boolean function indicating which items to process. Only items
		 *  for which this function return true will be considered by the
		 *  labeler. If the function is null, all items will be considered.
		 *  @see flare.util.Filter */
		public function get filterFn():Function {
			return _filter;
		}
		
		public function set filterFn(f:*):void {
			_filter = Filter.$(f);
			updateMapper();
		}
		
		
		/** An identifier for this mapper */
		public function get name():String {
			return _name;
		}
		
		public function set name(b:String):void {
			_name = b;
		}
		
		private var _enabled:Boolean = true;
		
		/** Indicates if the mapper is enabled or disabled. */
		public function get enabled():Boolean {
			return _enabled;
		}
		
		public function set enabled(b:Boolean):void {
			_enabled = b;
		}
		
		private var _immediate:Boolean = false;
		
		/** Indicates if the mapper is applied immediately. */
		public function get immediate():Boolean {
			return _immediate;
		}
		
		public function set immediate(b:Boolean):void {
			_immediate = b;
		}
		
		/** @inheritDoc */
		public function set parameters(params:Object):void
		{
			applyParameters(this, params);
		}
		
        
        /**
         * Optional property indicating where to find the visual element
         */
        public var visualElementProperty:String;
        
        
		// -- Methods ---------------------------------------------------------
		
        /**
         * Performs an operation over the contents of a visualization.
         * @param t a Transitioner instance for collecting value updates.
         * @param visualElementProperty an optional indicator of where to find the visual element
         */
        public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void {
            // for sub-classes to implement
        }
        
        /**
         * Performs an distortion over the contents of a visualization.
         * 
         * Distortions are performed immediately.
         */
        public function distort(items:ArrayCollection, e:Event, visualElementProperty:String=null):void {
            // for sub-classes to implement
        }
        
		
		/**
		 * Updates the encoder after a change to encoding parameters
		 */
		protected function updateMapper(e:Event=null):void
		{
			if (enabled) {
				dispatchEvent(new PropertyChangeEvent(PropertyChangeEvent.PROPERTY_CHANGE,
					true, false, PropertyChangeEventKind.UPDATE, 'ignore', null, null, this));
			}
		}
		
		
		
		// -- MXML ------------------------------------------------------------
		
		/** @private */
		public function initialized(document:Object, id:String):void
		{
			// do nothing
		}
		
		// -- Parameterization ------------------------------------------------
		
		/**
		 * Static method that applies parameter settings to an operator.
		 * @param op the operator
		 * @param p the parameter object
		 */
		public static function applyParameters(op:IMapper, params:Object):void
		{
			if (op == null || params == null) return;
			var o:Object = op as Object;
			for (var name:String in params) {
				var p:Property = Property.$(name);
				var v:* = params[name];
				var f:Function = v as Function;
				if (v is IEvaluable) f = IEvaluable(v).eval;
				p.setValue(op, f == null ? v : f(op));
			}
		}
		
		/** Constructor */
		public function MapperBase():void {			
			super();
		}
		
	} // end of class Operator
}