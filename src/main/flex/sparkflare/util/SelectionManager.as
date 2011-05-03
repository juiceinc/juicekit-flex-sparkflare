package sparkflare.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.collections.IList;
	import mx.controls.Alert;
	import mx.events.CollectionEvent;
	
	import org.juicekit.util.Property;
	
	import spark.components.DataGroup;
	import spark.components.IItemRenderer;
	import spark.components.supportClasses.ItemRenderer;
	import spark.events.RendererExistenceEvent;
	
	/**
	 * Manages selection of items in a DataGroup. Selected items are stored in 
	 * <code>selectedItems</code>. 
	 * 
	 * Use with a SelectionMapper to apply the selectedItems to properties in ItemRenderers. 
	 * 
	 * @see sparkflare.mappers.SelectionMapper
	 */
	public class SelectionManager extends EventDispatcher implements ISelectionManager
	{
		
		//-----------------------------
		//
		// Constants
		//
		//-----------------------------
		
		/** Select only one element at a time */
		public static const SELECT_ONE:String = 'selectOne';
		/** Select multiple elements at a time starting with zero elements selected */
		public static const SELECT_MANY:String = 'selectMany';
		/** Select multiple elements at a time starting with all elements selected */
		public static const SELECT_MANY_DEFAULT_SELECTED:String = 'selectManyDefaultSelected';
		
		
		//-----------------------------
		//
		// Properties
		//
		//-----------------------------
		
		/**
		 * Has the user performed any selection yet.
		 */
		protected var userSelectionReceived:Boolean = false;
		
		
		//-----------------------------
		// dataGroup
		//-----------------------------
		
		[Bindable] public var _dataGroup:DataGroup;
		

		public function set dataGroup(v:DataGroup):void 
		{
			var len:int;
			var i:int;
			var rend:IItemRenderer;
			
			// Remove event handlers from old group
			if (_dataGroup)
			{
				_dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, addClickHandler);
				_dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, removeClickHandler);
				len = _dataGroup.numElements;
				for (i=0; i<len; i++)
				{
					rend = _dataGroup.getElementAt(i) as IItemRenderer;
					if (rend)
						rend.removeEventListener(MouseEvent.CLICK, itemClicked);
				}
			
			}
			
			_dataGroup = v;

			// Add handlers to new group
			if (_dataGroup)
			{
				// TODO: this doesn't seem to catch all data provider changes
				BindingUtils.bindSetter(dataProviderSetterHandler, _dataGroup, 'dataProvider', false, true);
				
				// Add event handlers
				_dataGroup.addEventListener(RendererExistenceEvent.RENDERER_ADD, addClickHandler);
				_dataGroup.addEventListener(RendererExistenceEvent.RENDERER_REMOVE, removeClickHandler);
				
				len = _dataGroup.numElements;
				for (i=0; i<len; i++)
				{
					rend = _dataGroup.getElementAt(i) as IItemRenderer;
					if (rend)
						rend.addEventListener(MouseEvent.CLICK, itemClicked);
				}
			}
			
			selectionInit();
		}
		
		
		public function get dataGroup():DataGroup
		{
			return _dataGroup;
		}
		
		
		//-----------------------------
		// selectionMode
		//-----------------------------
		
		private var _selectionMode:String = SelectionManager.SELECT_ONE;

		[Inspectable(name="selectionMode",type="String",category="General",enumeration="selectOne,selectMany,selectManyDefaultSelected",default="selectOne")]
		public function set selectionMode(v:String):void 
		{
			if (_selectionMode != v) 
			{
				_selectionMode = v;
				selectionInit();
			}
		}
		
		public function get selectionMode():String 
		{
			return _selectionMode;
		}
		

		/**
		 * A property to use for matching. 
		 */
		private var _matchField:String;
		
		public function get matchField():String
		{
			return _matchField;
		}
		
		public function set matchField(value:String):void
		{
			_matchField = value;
			if (matchField) 
				matchProp = new Property(matchField);
			else
				matchProp = null;
			selectionInit();
		}
		
		/** A property that matches matchField */
		protected var matchProp:Property;
		
		
		/** 
		 * A lookup containing selected items. 
		 */
		public var selectedLookup:Dictionary = new Dictionary();
		
		

		//--------------------------------
		// Convenience methods
		//--------------------------------		
		
		/**
		 * Get value from an object. If an overrideField
		 * is provided use the field as a property name to get
		 * the value.
		 */
		protected function getValue(obj:Object, overrideField:String=null):Object
		{
			var propToUse:Property = matchProp;
			if (overrideField != null) {
				propToUse = Property.$(overrideField);
			}
			return propToUse == null ? obj : propToUse.getValue(obj); 
		}		
		
		protected function areNoneSelected(dataProvider:IList, lookup:Dictionary):Boolean {
			if (dataProvider)
			{
				for each (var item:Object in dataProvider)
				{
					if (lookup[getValue(item)] !== undefined)
						return false;
				}				
			}
			return true;
		}

		protected function areAllSelected(dataProvider:IList, lookup:Dictionary):Boolean {
			if (dataProvider)
			{
				for each (var item:Object in dataProvider)
				{
					if (lookup[getValue(item)] === undefined)
						return false;
				}				
			}
			return true;
		}
		
		protected function lookupSelectOnly(data:Object):void {
			selectedLookup = new Dictionary();
			selectedLookup[getValue(data)] = 1;
		}
		
		protected function lookupSelect(data:Object):void {
			selectedLookup[getValue(data)] = 1;
		}
		
		protected function lookupDeselect(data:Object):void {
			delete selectedLookup[getValue(data)];
		}
		
		protected function lookupSelectNone():void {
			selectedLookup = new Dictionary();
		}
		
		protected function lookupSelectAll(dataProvider:IList):void {
			lookupSelectNone();
			for each (var item:Object in dataProvider)
			{
				lookupSelect(item);
			}
		}
				
		
		
		//--------------------------------
		// Methods
		//--------------------------------
		
		
		/**
		 * Sets up initial state of selectedLookup based on selection strategy
		 */
		protected function selectionInit(e:Event=null, dataProvider:IList=null):void 
		{
			if (dataProvider == null && dataGroup && dataGroup.dataProvider) 
				dataProvider = dataGroup.dataProvider;
			
			if (!userSelectionReceived && dataProvider)
			{
				if (selectionMode == SelectionManager.SELECT_MANY_DEFAULT_SELECTED)
				{
					lookupSelectAll(dataProvider);
				}
				else if (selectionMode == SelectionManager.SELECT_MANY)
				{
					lookupSelectNone();
				}
				else if (selectionMode == SelectionManager.SELECT_ONE)
				{
					lookupSelectNone();
				}
				dispatchEvent(new Event('selectionChanged'));
			}
		}
		
		/**
		 * Determine if the item is found in selectedLookup based on the
		 * value found in matchField.  overrideField is used if provided.
		 */
		public function isSelected(obj:Object, overrideField:String=null):Boolean {
			return !(selectedLookup[getValue(obj, overrideField)] === undefined)
		}

		public function resetSelection():void 
		{
			userSelectionReceived = false;
			selectionInit();
		}
		
		
		//--------------------------------
		// Event handling
		//--------------------------------
				
		protected function dataProviderSetterHandler(o:Object=null):void 
		{
			if (o is IList)
			{
				(o as IList).addEventListener(CollectionEvent.COLLECTION_CHANGE, selectionInit, false, 0, true);
				
				// TODO: This doesn't seem to work in all cases
				selectionInit(null, o as IList);
			}
		}

		/**
		 * When an item renderer from dataGroup is clicked, perform 
		 * a selection strategy to change selectedItems.
		 */
		public function itemClicked(e:MouseEvent):void {
			var data:Object = (e.currentTarget as ItemRenderer).data;
			
			// Select one thing at a time
			if (selectionMode == SelectionManager.SELECT_ONE)
			{
				lookupSelectOnly(data);
			}
				
			// Select multiple items but when all items are selected
			// clear the selected items
			else if (selectionMode == SelectionManager.SELECT_MANY)
			{
				if (selectedLookup[getValue(data)] === undefined) 
					lookupSelect(data);
				else
					lookupDeselect(data);

				if (areAllSelected(dataGroup.dataProvider, selectedLookup))
					lookupSelectNone();
			}
				
			// Start with everything selected (@see selectionInit) then when the 
			// first thing is selected, set it to the only thing selected and build
			// up from there.
			else if (selectionMode == SelectionManager.SELECT_MANY_DEFAULT_SELECTED)
			{
				if (areAllSelected(dataGroup.dataProvider, selectedLookup))
				{
					lookupSelectOnly(data);
				}
				else if (selectedLookup[getValue(data)] === undefined) {
					lookupSelect(data);
				} else {
					lookupDeselect(data);
					if (areNoneSelected(dataGroup.dataProvider, selectedLookup))
						lookupSelectAll(dataGroup.dataProvider);
				}
			}
			userSelectionReceived = true;
			dispatchEvent(new Event('selectionChanged'));
			dispatchEvent(new Event('itemClicked'));
		}
		
		
		/**
		 * Attach a click handler when item renderers are added 
		 */
		private function addClickHandler(e:RendererExistenceEvent):void {
			var rend:ItemRenderer = e.renderer as ItemRenderer;
			rend.addEventListener(MouseEvent.CLICK, itemClicked);
		}
		
		
		/**
		 * Remove a click handler when item renderers are removed 
		 */
		private function removeClickHandler(e:RendererExistenceEvent):void {
			var rend:ItemRenderer = e.renderer as ItemRenderer;
			rend.removeEventListener(MouseEvent.CLICK, itemClicked);
		}
		
		
		
		//--------------------------------
		// Constructor
		//--------------------------------
		
		public function SelectionManager(dataGroup:DataGroup=null, selectionMode:String='selectOne', matchField:String=null)
		{
			if (dataGroup)
				this.dataGroup = dataGroup;
			this.selectionMode = selectionMode;
			this.matchField = matchField;
		}
	}
}