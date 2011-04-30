package sparkflare.util
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;
	
	import spark.components.DataGroup;
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
	public class SelectionManager
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
			var rend:ItemRenderer;
			
			// Remove event handlers from old group
			if (_dataGroup)
			{
				_dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_ADD, addClickHandler);
				_dataGroup.removeEventListener(RendererExistenceEvent.RENDERER_REMOVE, removeClickHandler);
				len = _dataGroup.numElements;
				for (i=0; i<len; i++)
				{
					rend = _dataGroup.getElementAt(i) as ItemRenderer;
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
					rend = _dataGroup.getElementAt(i) as ItemRenderer;
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
		 * The set of selected items 
		 */
		[Bindable] public var selectedItems:ArrayCollection = new ArrayCollection();
		
		
		//--------------------------------
		// Methods
		//--------------------------------

		/**
		 * Sets up initial state of selectedItems based on selection strategy
		 */
		protected function selectionInit(e:Event=null):void 
		{
			if (selectionMode == SelectionManager.SELECT_MANY_DEFAULT_SELECTED &&
				!userSelectionReceived && 
				dataGroup && 
				dataGroup.dataProvider)
			{
				selectedItems.removeAll();
				for each (var item:Object in dataGroup.dataProvider)
				{
					selectedItems.addItem(item);		
				}
			}
			else if (selectionMode == SelectionManager.SELECT_MANY &&
				!userSelectionReceived && 
				dataGroup && 
				dataGroup.dataProvider)
			{
				selectedItems.removeAll();
			}
			else if (selectionMode == SelectionManager.SELECT_ONE &&
				!userSelectionReceived && 
				dataGroup && 
				dataGroup.dataProvider)
			{
				selectedItems.removeAll();
			}
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
			trace('dataProvider setter');
			if (o is ArrayCollection)
			{
				(o as ArrayCollection).addEventListener(CollectionEvent.COLLECTION_CHANGE, selectionInit, false, 0, true);
			}
			selectionInit();
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
				selectedItems.removeAll();
				selectedItems.addItem(data);
			}
				
				// Select multiple items but when all items are selected
				// clear the selected items
			else if (selectionMode == SelectionManager.SELECT_MANY)
			{
				if (selectedItems.contains(data)) {
					selectedItems.removeItemAt(selectedItems.getItemIndex(data));
				} else {
					selectedItems.addItem(data);
				}
				if (selectedItems.length >= dataGroup.dataProvider.length) {
					selectedItems.removeAll();
				}
			}
				
				// Start with everything selected (@see selectionInit) then when the 
				// first thing is selected, set it to the only thing selected and build
				// up from there.
			else if (selectionMode == SelectionManager.SELECT_MANY_DEFAULT_SELECTED)
			{
				if (selectedItems.length >= dataGroup.dataProvider.length) {
					selectedItems.removeAll();
					selectedItems.addItem(data);
				}
				else if (selectedItems.contains(data)) {
					selectedItems.removeItemAt(selectedItems.getItemIndex(data));
				} else {
					selectedItems.addItem(data);
				}
			}
			userSelectionReceived = true;
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
		
		public function SelectionManager(dataGroup:DataGroup=null, selectionMode:String='selectOne')
		{
			if (dataGroup)
				this.dataGroup = dataGroup;
			this.selectionMode = selectionMode;
		}
	}
}