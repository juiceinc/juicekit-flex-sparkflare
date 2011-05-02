package sparkflare.util
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import org.juicekit.util.Filter;

	public class ConditionManager extends EventDispatcher implements ISelectionManager
	{

		private var _expression:Function;
		
		public function set expression(value:*):void {
			_expression = Filter.$(value);
			dispatchEvent(new Event('selectionChanged'));
		}
		
		public function isSelected(obj:Object):Boolean {
			return _expression(obj);
		}
		
		public function ConditionManager()
		{
		}
	}
}