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
	 * x, y, height, and width. VerticalStackLayout lays items out in vertical
	 * stack. It can simulate the Grid layout behavior if the groups (defined by 
	 * <code>groupField</code>) have the same number of members.
	 */
	[Bindable]
	public class VerticalStackLayout extends MapperBase
	{
		
		/**
		 * Object property used to size the items
		 */ 
		public var sizeField:String;
		
		/**
		 * Property of the object used to group/stack together the items with the same values
		 */ 
		public var groupField:String;
		
		/**
		 * Horizontal gap between the items
		 */ 
		public var gapX:Number = 2;
		
		/**
		 * Vertical gap between the items
		 */ 
		public var gapY:Number = 1;
		
		/**
		 * An optional parameter to set all items to the same height. <code>sizeField</code> is
		 * ignored if <code>fixedHeight</code> is set to any number.
		 */ 
		public var fixedHeight:Number = NaN;
		
		public var sortField:String;
		
		/** @inheritDoc */
		override public function operate(items:ArrayCollection, t:Transitioner = null, visualElementProperty:String=null, doImmediate:Boolean=false):void
		{
			var row:Object;
			var v:Number;
			
			if (enabled) 
			{
				var _t:Transitioner = (t != null ? t : Transitioner.DEFAULT);
				var restoreImmediate:Boolean = _t.immediate;
				if (immediate || doImmediate) _t.immediate = true;

				var sizeProp:Property = Property.$(sizeField);
				var groupProp:Property = Property.$(groupField);
				
				if (items) 
				{
					var ttl:Number = 0;
					var ownerWidth:Number = NaN;
					var ownerHeight:Number = NaN;
					
					var groupsMap:Object = {};
					var groupsTotal:Object = {};
					var groupName:String;
					var numGroups:int = 0;
					
					Sort.sortArrayCollectionBy(items, [groupField, sizeField]);
					
					//group items based on groupField property
					for each (row in items) 
					{
						v = Number(sizeProp.getValue(row));
						ttl += v > 0 ? v : 0;
						
						//classify items by groupNames
						groupName = groupProp.getValue(row);
						if(!groupsMap.hasOwnProperty(groupName))
						{
							numGroups++;
							groupsMap[groupName] = [];
							groupsTotal[groupName] = 0;
						}
						(groupsMap[groupName] as Array).push(row);
						groupsTotal[groupName] += v;
						
						if (isNaN(ownerWidth)) {
							ownerHeight = row.owner.height;
							ownerWidth = row.owner.width;
						}
					}
					
					var x:Number = 0;
					var y:Number = 0;
					var height:Number = 0;
					var width:Number = ownerWidth / numGroups - (numGroups -1)*gapX;
					
					var maxGroup:Number = 0;
					for (groupName in groupsTotal) 
					{
						maxGroup = (maxGroup < groupsTotal[groupName]) ? groupsTotal[groupName] : maxGroup;
					}
					var groupTotal:Number = 0;
					var groupArray:Array;
					var usableHeight:Number = 0;
					
					//position and size the items
					for (groupName in groupsMap)  
					{
						y = ownerHeight;
						groupTotal = groupsTotal[groupName];
						groupArray = groupsMap[groupName] as Array;
						groupArray.reverse();
						if(isNaN(fixedHeight)) usableHeight = ownerHeight * groupTotal/maxGroup - (groupArray.length-1)*gapY;
						
						for each (row in groupArray)
						{
							v = Number(sizeProp.getValue(row));
							height = isNaN(fixedHeight) ?  v/groupTotal * usableHeight : fixedHeight;
							y=y - (height+gapY);
							_t.setValue(row, 'height', height);
							_t.setValue(row, 'width', width);
							_t.setValue(row, 'x', x);
							_t.setValue(row, 'y', y);
						}
						x += width + gapX;
					}
				}
				
				_t.immediate = restoreImmediate;
				_t = null;
			}
		}
		
		
	}
}