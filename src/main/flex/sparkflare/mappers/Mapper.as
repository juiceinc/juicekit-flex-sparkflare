
package sparkflare.mappers
{  
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.collections.ListCollectionView;
	import mx.events.CollectionEvent;
	import mx.events.PropertyChangeEvent;
	import mx.events.PropertyChangeEventKind;
	import mx.geom.TransformOffsets;
	
	import org.juicekit.animate.Transitioner;
	import org.juicekit.palette.IPalette;
	import org.juicekit.palette.Palette;
	import org.juicekit.palette.SizePalette;
	import org.juicekit.scale.LinearScale;
	import org.juicekit.scale.Scale;
	import org.juicekit.util.Filter;
	import org.juicekit.util.Property;
	
	import spark.components.supportClasses.ItemRenderer;
	
	/**
	 * Dispatched when the mapping has changed
	 *
	 * @eventType flash.events.Event
	 */
	[Event(name="updateMapper", type="flash.events.Event")]
	
	
	
	/**
	 * Base class for Operators that perform encoding of visual variables such
	 * as color, shape, and size. All Encoders share a similar structure:
	 * A source property (e.g., a data field) is mapped to a target property
	 * (e.g., a visual variable) using a <tt>ScaleBinding</tt> instance to map
	 * between values and a <tt>Palette</tt> instance to map scaled output
	 * into visual variables such as color, shape, and size.
	 */
	[Bindable]
	public class Mapper extends MapperBase
	{
		/** Boolean function indicating which items to process. */
		protected var _filter:Function;
		/** A transitioner for collecting value updates. */
		protected var _t:Transitioner;
		/** The source property name */
		protected var _source:String;
		protected var sourceProp:Property;
		/** The target property name. */
		protected var targetProp:Property;
		protected var _target:String;
		/** Storage for the palette */
		protected var _palette:IPalette;
		/** Storage for the scale */		
		protected var _scale:Scale;
		/** Storage for a custom encoder function */
		protected var _customEncoder:Function;
		
		
		/** A scale binding to the source data. */
		public function get scale():Scale {
			return _scale;
		}
		
		public function set scale(s:Scale):void {
			if (s is Scale) {
				if (scale) _scale.removeEventListener(Scale.UPDATE_SCALE, updateMapper);
				_scale = s;
				_scale.addEventListener(Scale.UPDATE_SCALE, updateMapper);
				updateMapper();        
			}
		}
		
		/**
		 * Set the mapper's scale maximum value
		 */
		public function set sourceMax(v:Object):void {
			scale.max = v;
			updateMapper();
		}
		
		public function get sourceMax():Object {
			return scale.max;
		}
		
		/**
		 * Set the mapper's scale minimum value
		 */
		public function set sourceMin(v:Object):void {
			scale.min = v;
			updateMapper();
		}
		
		public function get sourceMin():Object {
			return scale.min;
		}
		
		
		/**
		 * Set the mapper's scale maximum value
		 */
		public function set targetMax(v:Object):void {
			palette['max'] = Number(v);
			updateMapper();
		}
		
		public function get targetMax():Object {
			return palette['max'];
		}
		
		/**
		 * Set the mapper's scale minimum value
		 */
		public function set targetMin(v:Object):void {
			palette['min'] = Number(v);
			updateMapper();
		}
		
		public function get targetMin():Object {
			return palette['min'];
		}
		
		
		/**
		 * Set the mapper's palette is2D property.
		 */
		public function set targetIs2D(v:Object):void {
			if ((palette as Object).hasOwnProperty('is2D'))
			{
				if (palette['is2D'] != Boolean(v)) {
					palette['is2D'] = Boolean(v);
					updateMapper();
				}
			}
		}
		
		public function get targetIs2D():Object {
			if ((palette as Object).hasOwnProperty('is2D'))
				return palette['is2D'];
			else 
				return false;
		}
		
		
		
		private var _hideItemsOutOfRange:Boolean = false;
		
		/**
		 * Hide elements that are outside of the scale range 
		 */
		public function set hideItemsOutOfRange(v:Object):void {
			if (_hideItemsOutOfRange != v) {
				_hideItemsOutOfRange = v;
				updateMapper();
			}
		}
		
		public function get hideItemsOutOfRange():Boolean {
			return _hideItemsOutOfRange;
		}
		
		
		
		private var _binCount:int = -1;
		/**
		 * Set the encoder's palette length
		 */
		public function set binCount(v:int):void {
			if (v == 0) v = -1;
			if (palette && v != _binCount) {
				_binCount = v;
				palette['binCount'] = v;
				updateMapper();
			}
		}
		
		public function get binCount():int {
			return _binCount;
		}
		
		
		protected var _requiredState:String;
		public function set requiredState(state:String):void {
			_requiredState = state;
		}
		
		
		/** The source property. */
		public function get sourceField():String {
			return _source;
		}
		
		public function set sourceField(f:String):void {
			if (_source != f) {
				_source = f;
				sourceProp = new Property(f);
				updateMapper();
			}
		}
		
		/** The target property. */
		public function get targetField():String {
			return _target;
		}
		
		public function set targetField(f:String):void {
			if (_target != f) {
				_target = f;
				targetProp = new Property(f);
				updateMapper();
			}
		}
		
		
		/** The palette used to map scale values to visual values. */
		public function get palette():IPalette {
			return _palette;
		}
		
		public function set palette(p:*):void {
			_palette = p;			
		}
		
		
		// --------------------------------------------------------------------
		
		/**
		 * Creates a new Mapper.
		 * @param source the source property
		 * @param target the target property
		 * @param filter a filter function controlling which items are encoded
		 */
		public function Mapper(source:String = null, target:String = null, filter:* = null)
		{
			_source = source;
			_target = target;
			this.filterFn = filter;			
			
			this.scale = new LinearScale();
			this.palette = new SizePalette();
			if (_binCount != -1) {
				(this.palette as SizePalette).binCount = _binCount;
			}
		}
		
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			const hideItems:Boolean = hideItemsOutOfRange;

			if (enabled) {
				_t = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;
				
				_t = (t != null && !immediate ? t : Transitioner.DEFAULT);
				
				var p:Property = Property.$(_source);
				
				var targetProp:Property = Property.$(_target);
				if (items) {
					items.disableAutoUpdate();
					for each (var row:Object in items) {
						if (row) { 
							var oldValue:Object = targetProp.getValue(row);
							var val:* = p.getValue(row);
							if (hideItems) {
								if (val < sourceMin  || val > sourceMax) {
									_t.setValue(row, 'alpha', 0.01);
								} else {
									_t.setValue(row, 'alpha', 1);
								}
							}
							var newValue:Object = encode(val);
							_t.setValue(row, _target, newValue);
							items.itemUpdated(row, _target, oldValue, newValue);
						}
					}
					items.enableAutoUpdate();
				}
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		/** @inheritDoc */
		override public function distort(items:ArrayCollection, e:Event, visualElementProperty:String=null):void
		{
			if (enabled) {
				var p:Property = Property.$(_source);
				var targetProp:Property = Property.$(_target);
				var pt:Point = new Point();
				var stagePt:Point;
				const PI:Number = 3.141592; 
				
				if (items) {
					for each (var row:Object in items) {
						if (row) { 
							var rend:ItemRenderer = row as ItemRenderer;
							var offsets:TransformOffsets = rend.postLayoutTransformOffsets;
							if (offsets == null) {
								rend.postLayoutTransformOffsets = new TransformOffsets();
								offsets = rend.postLayoutTransformOffsets;
							}
							
							if (e.type == MouseEvent.MOUSE_DOWN) {
								offsets.x = 50*Math.random();
							}
							if (e.type == MouseEvent.MOUSE_UP) {
								offsets.x = 0;
								offsets.y = 0;
								offsets.z = 0;
								offsets.scaleX = 1;
								offsets.scaleY = 1;
							}
							if (e.type == MouseEvent.MOUSE_MOVE) {
								var me:MouseEvent = e as MouseEvent;
								pt.x = 0;
								pt.y = 0;
								offsets.z = 0;
								stagePt = rend.localToGlobal(pt);
								
								var distX:Number = (stagePt.x - me.stageX);
								var distY:Number = (stagePt.y - me.stageY);
								
								
								var dist:Number = Math.sqrt(distX*distX+ distY*distY);
								var sign:Number = distX > 0 ? 1 : -1;
								if (Math.abs(dist) < 100) {
									dist = PI * dist / 100;
									var amt:Number = 0.5*(Math.cos(dist) + 1);
									offsets.x = amt * distX;
									offsets.y = amt * distY;
									//offsets.z = amt * -10;
									offsets.scaleX = 1+amt;
									offsets.scaleY = 1+amt;
								} else {
									offsets.x = 0;
									offsets.y = 0;
									offsets.z = 0;
									offsets.scaleX = 1;
									offsets.scaleY = 1;
								}
							}
							if (e.type == MouseEvent.ROLL_OUT) {
								offsets.x = 0;
								offsets.y = 0;
								offsets.z = 0;
								offsets.scaleX = 1;
								offsets.scaleY = 1;
							}
							//                            var newValue:Object = encode(p.getValue(row));
							//                            targetProp.setValue(offsets, newValue);
						}
					}
				}
				
				_t = null;
			}
		}
		
		
		public function get customEncoder():Function
		{
			return _customEncoder;
		}
		
		/**
		 * A custom function for performing value encodings. If
		 * set, this overrides the encoder using palette and scale.
		 * 
		 * The function signature is:
		 * 
		 * <code>
		 * function(val:Object, mapper:IMapper):*
		 * </code>
		 * 
		 */		
		public function set customEncoder(f:Function):void 
		{
			_customEncoder = f;
		}
		
		
		/**
		 * Computes an encoding for the input value.
		 * 
		 * @param val a data value to encode
		 * @return the encoded visual value
		 */
		[Bindable(event="updateMapper")]
		public function encode(val:Object):*
		{
			if (customEncoder) 
			{
				return customEncoder(val, this);
			}
			else
			{
				return palette.getValue(scale.interpolate(val));
			}
		}
		
	} // end of class Encoder
}